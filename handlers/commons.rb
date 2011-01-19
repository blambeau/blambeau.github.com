begin
  require 'wlang'
  require 'wlang/ext/hash_methodize'
rescue LoadError
  require 'rubygems'
  retry
end
begin
  require "albino"
rescue LoadError
  require 'rubygems'
  retry
end
require 'yaml'
require 'fileutils'

WLang::dialect('revzero', '.r0') do 
  ruby_require "cgi", "wlang/dialects/xhtml_dialect" do
    encoders WLang::EncoderSet::XHtml
    rules WLang::RuleSet::Basic
    rules WLang::RuleSet::Encoding
    rules WLang::RuleSet::Imperative
    rules WLang::RuleSet::Buffering
    rules WLang::RuleSet::Context
    rules WLang::RuleSet::XHtml
    post_transform "redcloth/xhtml"
    
    # Add the rule to code highlight things
    rule "#<" do |parser, offset|
      uri, lexer = nil
      uri, reached = parser.parse(offset, "wlang/uri")
      if parser.has_block?(reached)
        lexer = uri.to_sym
        text, reached = parser.parse_block(reached)
        highlighted = Albino.colorize(text, lexer)
        ["<notextile>#{highlighted}</notextile>", reached]
      else
        file = parser.template.file_resolve(uri, false)
        if File.file?(file) and File.readable?(file)
          lexer = File.extname(file)[1..-1].to_sym
          lexer = :text if lexer == :r0
          highlighted = Albino.colorize(File.read(file), lexer)
          ["<notextile>#{highlighted}</notextile>", reached]
        else
          text = parser.parse(offset, "wlang/dummy")[0]
          parser.error(offset, "unable to apply highligh rule #<{#{text}}, not a file or not readable (#{file})")
        end
      end
    end
    
  end
end

# Some reusable paths
if ARGV[0] == '--analytics'
  $analytics = true
  ARGV.shift
else
  $analytics = false
end
$here = File.dirname(__FILE__)
$top = File.join($here, '..')
$src = File.join($top, 'src')
$public = File.join($src, 'public')
$articles = File.join($src, 'articles')
$templates = File.join($src, 'templates')
$handler_templates = File.join($src, 'handlers')
$output = File.join($top, 'output')

# The information writings.yaml
$info = YAML::load(File.read(File.join($src, 'articles', 'writings.yaml')))

# Create the output directory if not already present
FileUtils.mkdir($output) unless File.exists?($output)

def relativize(file, from)
  File.expand_path(file)[from.length+1..-1]
end

# Copy the public folder somewhere. 
def copy_public(to)
  FileUtils.mkdir(to) unless File.exists?(to)
  FileUtils.mkdir(File.join(to, 'downloads')) unless File.exists?(File.join(to, 'downloads'))
  Dir[File.join($public, '**', '*')].each do |file|
    relfile = relativize(File.expand_path(file), File.expand_path($public))
    target = File.join(to, relfile)
    FileUtils.mkdir_p(File.dirname(target)) unless File.exists?(target)
    FileUtils.cp_r(file, target) if File.file?(file)
  end
end

# Creates a wlang context for a given writing/index pair
def wlang_context(writing = nil, index = $info.writings.index(writing))
  context = {:info => $info, 
             :writing => writing, 
             :current_index => index, 
             :current => writing ? writing.identifier : -1,
             :analytics => $analytics}
end

# WLang-composes _template_file_ in _output_folder_ for the page whose
# url is given and with a given context
def compose_page(template_file, output_folder, writing, url = writing.identifier, context = wlang_context(writing))
  target_file_name = "".external_to_internal(url)
  File.open(File.join(output_folder, target_file_name), 'w') do |io|
    io << WLang::file_instantiate(template_file, context)
  end
end

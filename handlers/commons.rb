begin
  require 'wlang'
  require 'wlang/ext/hash_methodize'
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

if $0 == __FILE__
  test_r0 = File.expand_path('../test/test.r0', __FILE__)
  puts WLang::file_instantiate(test_r0, {}, "revzero")
end
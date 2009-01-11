#!/usr/bin/env ruby
require 'rubygems'
require 'rdoc/markup/to_html'
require 'htmlentities'
require 'fileutils'

include FileUtils

#
# Extension of RDoc::Markup::ToHtml generator. This class is not intended to be
# instanciated directly, use RevZeroMarkupRecognizer#parse instead.
#
# This class installs the following recognization patterns:
# - metatag{tag_contents}: does not generate anything but fills the Hash 
#   with <tt>hash[metatag]=tag_contents</tt>
#
# Limitations:
# - Trailing <p></p> are generated when meta tags are parsed.
# - The hash to fill must be installed using the _metahash_ write accessor
#   (not with: <tt>RevZeroMarkupRecognizer.new(metahash)</tt> as expected)   
#
# Usage:
# - Due to limitations, this class is expected to be used as follows:
#       RevZeroMarkupRecognizer.parse(source, metahash) 
#
class RevZeroMarkupRecognizer < RDoc::Markup::ToHtml
  attr_writer :metahash
  
  # Regular expression for meta tags
  METATAG_REGEX = /([a-z_]+)\{([^\}]*)\}/

  # Regular expression for link tags
  LINK_REGEX = />\{([^\}]+)\}(\[([^\]]+)\])?/

  # Initializes the generator and installs the recognization extensions
  def initialize
    super
    @markup.add_special(METATAG_REGEX, :METATAG)
    @markup.add_special(LINK_REGEX, :LINKTAG)
    # this is due to something that looks like a but in RDoc::Markup::ToHtml
    instance_eval do
      @from_path = File.dirname(__FILE__)    end
  end
    
  # Handles a metatag recognition. Raises an RuntimeError if your metahash has
  # not been previously installed.
  def handle_special_METATAG(special)
    raise "Metatags Hash must be installed using metahash write accessor"\
      unless @metahash
    METATAG_REGEX =~ special.text
    @metahash[$1] = $2
    ""
  end
  
  # Handles generation for link ->{...} tags. Raises an RuntimeError if your
  # metahash has not been previously installed.
  def handle_special_LINKTAG(special)
	  LINK_REGEX =~ special.text
	  "<a href=\"#{$3 ? $3 : $1}\">#{$1}</a>"
	end

  #
  # Parses a source text and fills the _metahash_ argument. Generated contents
  # is installed in the hash under 'contents' key. Meta tag contents is installed 
  # under its own tag name. Returns _metahash_.
  #
  def self.parse(source, metahash={})
    h = RevZeroMarkupRecognizer.new
    h.metahash = metahash
    metahash["contents"] = h.convert(source)
    metahash
  end
  
end

#
# Instanciates a revision-zero template.
#
class RevZeroTemplateInstanciator
  
  #
  # Creates an instanciator instance. _path_ is expected to be the path to
  # an existing file. Raises an ArgumentError if the file does not exists or is
  # not readable.
  #
  def initialize(path)
    raise(ArgumentError, 
          "Template file #{path} does not exists") unless File.exists?(path)
    raise(ArgumentError, 
          "Template file #{path} cannot be read") unless File.readable?(path)
    @template = path
    @encoder = HTMLEntities.new
  end
  
  # Finds the next block in a string
  def find_sub_block(str)
    raise "Syntax error in sub block, { expected #{str[0,1]} found"\
      unless str[0,1]=='{'
    index=0
    count=0
    while index<str.length
      if (c=str[index,1])=='{'
        count += 1
      elsif c=='}'
        count -= 1
        if count==0 
          return [str[1,index-1], str[index+1,str.length-index]]
        end
      end  
      index += 1
    end
    raise "Syntax error in subblock: no } terminator"
  end
  
  # Instanciates a given string _str_
  def instanciate_str(line, hash, buffer)
    # matches ${...}, +{...} and @{...}, first group is operator, second is varname
    while matchdata=/([$+@!*])\{([^\}]+)\}/.match(line)
      tagtype, varname = matchdata[1], matchdata[2]
      buffer << matchdata.pre_match  # pre_match is send to buffer
      case tagtype
      when '$' # reference to a variable (encoding required)
        raise "No data found for #{varname} (#{hash.keys.inspect})" unless hash.has_key?(varname)
        buffer << @encoder.encode(hash[varname])
      when '@' # reference to an action, we use singleton methods here
        raise "Action #{varname} not found" unless self.respond_to?(varname)
        buffer << self.send(varname)
      when '+' # Template inclusion (no encoding)
        raise "No data found for #{varname}" unless hash.has_key?(varname)
        buffer << hash[varname]
      when '!' # Ruby execution
        buffer << Kernel.eval(varname)
      when '*'
        raise "No data found for #{varname}" unless hash.has_key?(varname)
        # get infos
        items = hash[varname]
        raise "Non enumerable variable #{varname}" unless items.respond_to?(:each)
        # find sub block and next line
        blockstr, line = find_sub_block(matchdata.post_match)
        items.each do |i|
          instanciate_str(blockstr, i, buffer)
        end
        next
      end
      # continue with post_match (which can contain other tags)
      line = matchdata.post_match
    end
    buffer << line # trailing contents send to buffer
  end
  
  #
  # Instanciates the _wlang_ template using key/value pairs given by _hash_. _buffer_ is 
  # expected to be an IO object on which template generation output is written 
  # Raises a RuntimeError if a reference to an unexisting variable is found.
  #
  # Following markups are recognized:
  # - ${varname} are replaced by the entities-encoding of hash[varname] 
  # - +{varname} are replaced by hash[varname] without encoding
  # - @{varname} are replaced by the result returned by the _varname_ singleton
  #              method. It is required to install those singleton methods
  #              before launching the generation!
  #
  def instanciate(hash, buffer)
    # read all lines as a single line
    line = nil
    File.open(@template, "r") {|f| line = f.readlines().join()}
    instanciate_str(line, hash, buffer)
  end  
  
end # RevZeroTemplateInstanciator

#
# Generates the revision number _revision_, from the article _source_ (path to
# the article file) inside the file _target_ (path to the .html output file).
#
# Raises an ArgumentError if _source_ does not exists or is not readable or if
# _target_ file cannot be written.
#
def generate(revision, source, target)
  raise(ArgumentError, 
        "Article file #{source} does not exists") unless File.exists?(source)
  raise(ArgumentError, 
        "Article file #{source} cannot be read") unless File.readable?(source)
  raise(ArgumentError, 
        "Target file #{target} cannot be accessed") \
        unless File.writable?(target) or \
        (not(File.exists?(target)) and File.writable?(File.dirname(target)))

  # Parse the given article and fill my hash with contents 
  meta = nil
  File.open(source, "r") do |f| 
    meta = {}
    meta.merge!($shared)
    meta = RevZeroMarkupRecognizer.parse(f.readlines().join(), meta)
  end

  # Now, instanciate the template with the result
  File.open(target,"w") do |f| 
    $current = revision
    def $instanciator.prev()
      ($current == 0 ? 0 : ($current-1)).to_s
    end
    def $instanciator.next()
      ($current + 1).to_s
    end
    $instanciator.instanciate(meta, f)
  end
  
  # return meta
  return meta
end

# Checks the options, return nil if everything is ok, an error message 
# otherwise
def check_options
  return "Unexisting source folder #{$articles}" unless File.directory?($articles)
  return "Unable to access source folder (read) #{$articles}" unless File.readable?($articles)
  return "Invalid articles extension #{$source_extension}" unless /\.[a-zA-Z0-9]+/ =~ $source_extension
  return "Unexisting output folder #{$output}" unless File.directory?($output)
  return "Unable to access output folder (write) #{$output}" unless File.writable?($output)
  return "Invalid output file extension #{$output_extension}" unless /\.[a-zA-Z0-9]+/ =~ $output_extension
  return "Missing index file #{$index}" unless File.file?($index)
  return "Unable to read index file #{$index}" unless File.readable?($index)
  return "Missing template file #{$template}" unless File.file?($template)
  return "Unable to read template file #{$template}" unless File.readable?($template)
end

# Returns generator usage
def usage
use = <<-USAGE
Usage: genrevzero [switches] [revnumber]

Without revnumber, generates all revision-zero html files from articles,
based on the index file #{$index}. Otherwise, generates the 
file for revnumber only.

  --copyright, -c             print the copyright
  --version, -v               print the version
  --help, -h                  show usage
  --shared, -Skey=value       install key/value pair inside shared hash (default: #{$shared.inspect})
  --from, -fpath              folder containing source articles (default: '#{$articles}')
  -iext                       file extension used for articles (default: '#{$source_extension}') 
  --to, -tpath                output folder of the generation (default: '#{$output}')
  -oext                       file extension used for generated files (default: '#{$output_extension}')
  --index, -Ipath             path to the index file (default: '#{$index}')
  --template, -Tpath          path to the template file (default: '#{$template}')
  --verbose                   verbose mode
  --fake                      fake mode, only print what would be done 
  --single source target      generates a single file (bypass --index, --from, --to, -i, -o)
  
USAGE
end

#
# Main variables of this script:
# [articles] path to the folder containing the articles files (default: 'articles')
# [source_extension] file extension of article files (default: '.r0')
# [index] path to the index file, containing (revision, filename) pairs (default: 'articles/revision-zero.index')
# [template] path to the template to use for instanciation (default: 'articles/template.wtpl')
# [output] output folder of the generation (default: 'public/statics')
# [output_extension] file extension of generated files (default: '.html')
# [shared] hash with key/value pairs shared by all pages   
# [verbose] verbose mode enabled?
# [fake] only say what it would do (enabled verbose mode by default)
# [revision] number of the revision to generate, nil for all
# [source] source file in single mode
# [target] target file in single mode
#
$articles = 'articles'
$source_extension = '.r0'
$index    = File.join($articles, 'revision-zero.index')
$template = File.join($articles, 'template.wtpl')
$output   = File.join('public','statics')
$output_extension = '.html'
$shared   = {"base" => "http://www.revision-zero.org/statics"}
$verbose  = false
$fake = false
$revision = nil
$source = nil
$target = nil
  
# Handles command-line options
i=0
arg = ARGV[i]
while (i<ARGV.size)
  case arg
    when '--copyright', '-c'
      puts "genrevzero - Copyright (C) 2008-2009, Bernard Lambeau (www.revision-zero.org)"
      exit
    when '--version', '-v'
      puts "genrevzero 0.1 (2009-01-11)"
      exit
    when '--help', '-h'
      puts usage
      exit
    when '--shared'
      i += 1; arg = '-S' << ARGV[i]; next
    when /^-S([^=]+)=("?.*"?|.*)$/
      $shared[$1] = $2
    when '--from'
      i += 1; arg = '-f' << ARGV[i]; next
    when /^-f(.*)$/
      $articles = $1
    when /^-i(.*)$/
      $source_extension = $1
    when '--to'
      i += 1; arg = '-t' << ARGV[i]; next
    when /^-t(.*)$/
      $output = $1
    when /^-o(.*)$/
      $output_extension = $1
    when '--index'
      i += 1; arg = '-I' << ARGV[i]; next
    when /^-I(.*)$/
      $index = $1
    when '--template'
      i += 1; arg = '-T' << ARGV[i]; next
    when /^-T(.*)$/
      $template = $1
    when '--verbose'
      $verbose = true
    when '--fake'
      $fake = true
      $verbose = true
    when '--single'
      $source = ARGV[i=i+1]
      $target = ARGV[i=i+1]
    else
      if /\d+/ =~ arg
        $revision = arg.to_i
      else
        puts "Invalid option #{arg}"
        puts usage
        exit 
      end
  end  
  i += 1
  arg = ARGV[i]
end

# check the options
if msg=check_options 
  puts msg
  exit(-1)
end

# Verbose mode? say what you are planning to do
if $verbose
  puts "Will generate " << ($revision ? "revision number #{$revision}" : "all revisions")
  puts "  source folder:          '#{$articles}'"
  puts "  source extension:       '#{$source_extension}'"
  puts "  output folder:          '#{$output}'"
  puts "  output extension:       '#{$output_extension}'"
  puts "  index file:             '#{$index}'"
  puts "  template file:          '#{$template}'"
  puts "Shared key/value pairs:"
  $shared.each_pair do |k,v|
    puts "  #{k} = #{v}"
  end
  puts
end
exit if $fake

# Number of the generated revision and template instanciator 
$instanciator = RevZeroTemplateInstanciator.new($template)

# Let's go now
if ($source and $target)
  # single mode
  puts "Generating single file: '#{$source}' -> '#{$target}'" if $verbose
  generate(-1, $source, $target)  
else
  metas = []
  # index file mode
  File.open($index) do |index|
    
    # generate html files
    index.each_with_index do |line, i|
      raise("Parse error in index on line #{i}: #{line}") \
        unless /(\d+)\s+([a-z_]+)/ =~ line
      if $revision.nil? or $revision==i
			  source_name, target_name = $2, $1
        source = File.join($articles, source_name + $source_extension)
        target = File.join($output, target_name + $output_extension)
	      symblink = File.join($output, source_name + $output_extension)
	      
	      # generate the .html file
        puts "Generating revision #{i}: '#{source}' -> '#{target}'" if $verbose
        meta = generate($1.to_i, source, target) 
        meta["revnumber"] = source_name
        metas << meta
        
        # create symbolic link
	      ln_s(target, symblink) unless File.exists?(symblink)
      end
    end
  end
    
  # generate RSS flux 
  template = File.join($articles, 'rss.wtpl')
  instanciator = RevZeroTemplateInstanciator.new(template)
  target = File.join($output, 'rss.xml')
  File.open(target, "w") do |f|
    metas.reverse!
    meta = {"items" => metas}
    instanciator.instanciate(meta, f)
  end 

end

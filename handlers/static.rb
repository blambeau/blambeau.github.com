require File.join(File.dirname(__FILE__), 'commons')

# We reopen the String class to tune some WLang 
# extension points
class String
  
  # Renders a link tag <a href="url">label</a> for the 
  # static version of the website
  def to_xhtml_link(url, label)
    "<a href=\"#{to_xhtml_href(url)}\">#{label}</a>"
  end
  
  # This method resolve number-based urls to identifier-based
  # ones (revision-zero uses a lot of numbers in source articles 
  # and templates).
  def to_xhtml_href(url)
    if /^[-]?\d+$/ =~ url.to_s.strip
      url = $info.writings[url.to_i]
      url = url ? url.identifier : "404"
    end
    "#{url}.html"
  end

end

# The static template to use
template = File.join($templates, 'static.wtpl')

# Copy public folder to output now
output = ARGV[0] || File.join($output, 'static')
FileUtils.rm_rf(output) if File.exists?(output)
copy_public(output)

# Converts each writing to an html file, using the static.wtpl
# template
$info.writings.each_with_index do |writing, index|
  File.open(File.join(output, "#{writing.identifier}.html"), 'w') do |io|
    io << WLang::file_instantiate(template, wlang_context(writing, index))
  end
end

# Converts each other (404, for instance) to an html file, using the 
# static.wtpl template. The only difference with previous iteration 
# is the index, which is set to info.writings.size
$info.others.each do |writing|
  File.open(File.join(output, "#{writing.identifier}.html"), 'w') do |io|
    io << WLang::file_instantiate(template, wlang_context(writing, $info.writings.size))
  end
end
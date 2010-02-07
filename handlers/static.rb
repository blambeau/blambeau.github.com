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
    case url.strip
      when /\.(css|js|gif|jpg|png|pdf|zip)$/
        url
      when /^[-]?\d+$/
        url = $info.writings[url.to_i]
        url = url ? url.identifier : "404"
        "#{url}.html"
      when 'rss'
        "rss.xml"
      else
        "#{url}.html"
    end
  end
  alias :external_to_internal :to_xhtml_href

end

# The static template to use
template = File.join($templates, 'static.wtpl')

# Copy public folder to output now
output = ARGV[0] || File.join($output, 'static')
FileUtils.rm_rf(output) if File.exists?(output)
copy_public(output)

# Converts each writing to an html file, using the static.wtpl template
$info.writings.each {|writing| compose_page(template, output, writing)}

# Converts the other ones
$info.others.each {|writing| 
  template = File.join($templates, "#{writing.template}.wtpl")
  compose_page(template, output, writing, writing.identifier, wlang_context(writing, $info.writings.size))
}

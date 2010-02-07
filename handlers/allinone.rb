require File.join(File.dirname(__FILE__), 'commons')
require 'base64'

def encode_image(imgfile)
  basename, ext, base64 = File.basename(imgfile), File.extname(imgfile), nil
  File.open(imgfile, 'r') {|io| base64 = Base64.encode64(io.read) }
  "data:image/#{ext[1..-1]};base64," << base64.gsub("\n","")
end
def css_embed
  cssfile = File.join($public, 'css', 'style.css')
  File.read(cssfile).gsub(/url\(..\/(.*)\)/){|url| 
    imgfile = $1 if (url =~ /url\(..\/(.*)\)/)
    imgfile = File.join($public, imgfile)
    "url(#{encode_image(imgfile)})"
  }
end

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
      when /\.(gif|jpg|png)$/
        imgfile = File.join($public, url)
        encode_image(imgfile)
      when /\.(css|js|pdf|zip)$/
        url
      when /^[-]?\d+$/
        url = $info.writings[url.to_i]
        url = url ? url.identifier : "404"
        "javascript:goto_page('#{url}')"
      when 'rss'
        "http://www.revision-zero.org/rss"
      else
        "javascript:goto_page('#{url}')"
    end
  end
  alias :external_to_internal :to_xhtml_href

end

# The static template to use
template = File.join($handler_templates, 'allinone.wtpl')

# Copy public folder to output now
output = ARGV[0] || File.join($output, 'revision-zero.html')

# Compose the layout now
context = wlang_context($info.writings[-1]).merge(:css => css_embed)
File.open(output, 'w') do |io|
  io << WLang::file_instantiate(template, context)
end

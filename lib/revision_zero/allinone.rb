require 'base64'
$root   = File.expand_path('../../../', __FILE__)
$public = File.join($root, 'public')
$info   = YAML::load File.read(File.join($root, 'src/articles/writings.yaml'))
$info.writings.each{|w|
  w['src_location'] = File.join($root, 'src/articles', "#{w.identifier}.r0")
}

def encode_image(imgfile)
  basename, ext, base64 = File.basename(imgfile), File.extname(imgfile), nil
  File.open(imgfile, 'r') {|io| base64 = Base64.encode64(io.read) }
  "data:image/#{ext[1..-1]};base64," << base64.gsub("\n","")
end

def css_embed(cssfile)
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
    puts "Managing #{url}"
    "<a onclick=\"#{to_xhtml_href(url)}\">#{label}</a>"
  end
  
  # This method resolve number-based urls to identifier-based
  # ones (revision-zero uses a lot of numbers in source articles 
  # and templates).
  def to_xhtml_href(url)
    case url.strip
      when /\.(gif|jpg|png)$/
        imgfile = File.join($public, url)
        puts "Embedding #{imgfile}"
        encode_image(imgfile)
      when /\.(css|js|pdf|zip|html)$/
        url
      when /^[-]?\d+$/
        url = $info.writings[url.to_i]
        url = url ? url.identifier : "404"
        "javascript:goto_page('#{url}')"
      when 'rss'
        "http://www.revision-zero.org/rss"
      else
        "goto_page('#{url}')"
    end
  end
  alias :external_to_internal :to_xhtml_href

end

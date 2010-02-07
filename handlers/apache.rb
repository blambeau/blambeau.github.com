require File.join(File.dirname(__FILE__), 'commons')

# We reopen the String class to tune some WLang 
# extension points
class String
  
  # Renders a link tag <a href="url">label</a> for the 
  # static version of the website
  def to_xhtml_link(url, label)
    "<a href=\"#{to_xhtml_href(url)}\">#{label}</a>"
  end
  
  # Returns the url (conversion is made by the .htaccess file)
  def to_xhtml_href(url)
    url
  end
  
  # Converts an external to an internal link
  def external_to_internal(url)
    case url
      when /\.(css|js|gif|jpg|png|pdf|zip)$/
        url
      when 'rss'
        'rss.xml'
      else
        "#{url}.html"
    end
  end

end

# The static template to use
template = File.join($templates, 'static.wtpl')

# Copy public folder to output now
output = ARGV[0] || File.join($output, 'apache')
FileUtils.rm_rf(output) if File.exists?(output)
copy_public(output)

# Copy the .htaccess file below to the output folder
FileUtils.cp(File.join($here, 'apache_htaccess.txt'), File.join(output, '.htaccess'))

# Converts each writing to an html file, using the static.wtpl template
$info.writings.each_with_index {|writing, index| 
  compose_page(template, output, writing)
  compose_page(template, output, writing, index.to_s)
  compose_page(template, output, writing, "-1") if index==$info.writings.size-1
}

# Converts the other ones
$info.others.each {|writing| 
  template = File.join($templates, "#{writing.template}.wtpl")
  compose_page(template, output, writing, writing.identifier, wlang_context(writing, $info.writings.size))
}

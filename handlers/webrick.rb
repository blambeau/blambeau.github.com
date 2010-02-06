require 'rubygems'
require 'webrick'
require 'wlang'
require 'wlang/ext/hash_methodize'

WLang::file_extension_map('.r0', 'wlang/xhtml')
class String
  
  def to_xhtml_link(url, label)
    "<a href=\"#{to_xhtml_href(url)}\">#{label}</a>"
  end
  
  def to_xhtml_href(url)
    "/#{url}"
  end
  
end

class WawStaticsWebrickServlet < WEBrick::HTTPServlet::AbstractServlet
  
  def initialize(server, root)
    @root = root
    @template = File.join(File.dirname(__FILE__), 'webrick.wtpl')
  end
  
  def do_GET(request, response)
    status, content_type, body = compose(request)
    response.status = status
    response['Content-Type'] = content_type
    response.body = body
  end
  
  def compose(request)
    in_public  = File.join(@root, 'src', 'public', request.path)
    if File.file?(in_public)
      type = case File.extname(in_public)
        when '.css'
          "text/css"
        when '.gif'
          "image/gif"
        when '.png'
          "image/png"
        when 'jpg'
          "image/jpg"
        when 'js'
          "text/javascript"
      end          
      [200, type, File.read(in_public)]
    else
      requested = $1 if request.path =~ /^\/(.*)$/
      requested = 'index' if requested.nil? or requested.empty?
      requested = 'born' if requested == 'index'
      requested = '404' unless File.exists?(File.join(@root, 'src', 'articles', "#{requested}.r0"))
      template = File.join(@root, 'src', 'templates', 'webrick.wtpl')
      begin
        [requested == '404' ? 404 : 200, 'text/html', WLang::file_instantiate(template, :current => requested)]
      rescue Exception => ex
        puts ex.message
        puts ex.backtrace.join("\n")
        back = (ex.respond_to?(:wlang_backtrace) ? ex.wlang_backtrace : ex.backtrace).join("\n")
        [500, 'text/plain', ex.message << "\n" << back]
      end
    end
  end
  
end

s = WEBrick::HTTPServer.new(
  :Port            => 8080,
  :DocumentRoot    => $root
)
s.mount('/', WawStaticsWebrickServlet, File.join(File.dirname(__FILE__), '..'))
trap("INT"){ s.shutdown }
puts "***************************************************************"
puts "* Perfect, have a look at http://127.0.0.1:8080/              *"
puts "***************************************************************"
begin
  s.start
rescue Interrupt
  s.stop
end
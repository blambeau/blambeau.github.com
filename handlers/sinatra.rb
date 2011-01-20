require 'rubygems'
require 'wlang'
require 'wlang/ext/hash_methodize'
require File.expand_path('../commons', __FILE__)
class String
  
  def to_xhtml_link(url, label)
    "<a href=\"#{to_xhtml_href(url)}\">#{label}</a>"
  end
  
  def to_xhtml_href(url)
    "/#{url}"
  end
  
end

require 'sinatra'
get '/:requested' do
  set :public, File.expand_path('../../src/public', __FILE__)
  begin
    template = File.expand_path('../../src/handlers/sinatra.wtpl', __FILE__)

    # find requested file
    requested = params[:requested]
    requested = 'index' if requested.nil? or requested.empty?
    requested = 'born' if requested == 'index'
    requested = '404' unless File.exists?(File.expand_path("../../src/articles/#{requested}.r0", __FILE__))
    
    WLang::file_instantiate(template, :current => requested)
  rescue WLang::Error => ex
    puts ex.message
    puts ex.wlang_backtrace
    "ko: #{ex.message}"
  end
end

# class WawStaticsWebrickServlet < WEBrick::HTTPServlet::AbstractServlet
#   
#   def initialize(server, root)
#     @root = root
#     @template = File.join(File.dirname(__FILE__), 'webrick.wtpl')
#   end
#   
#   def do_GET(request, response)
#     status, content_type, body = compose(request)
#     response.status = status
#     response['Content-Type'] = content_type
#     response.body = body
#   end
#   
#   def do_POST(request, response)
#     puts request.params.inspect
#     response.status = 200
#     response['Content-Type'] = "text/plain"
#     response.body = "ok"
#   end
#   
#   def compose(request)
#     in_public  = File.join(@root, 'src', 'public', request.path)
#     if File.file?(in_public)
#       type = case File.extname(in_public)
#         when '.css'
#           "text/css"
#         when '.gif'
#           "image/gif"
#         when '.png'
#           "image/png"
#         when 'jpg'
#           "image/jpg"
#         when 'js'
#           "text/javascript"
#       end          
#       [200, type, File.read(in_public)]
#     else
#       requested = $1 if request.path =~ /^\/(.*)$/
#       requested = 'index' if requested.nil? or requested.empty?
#       requested = 'born' if requested == 'index'
#       requested = '404' unless File.exists?(File.join(@root, 'src', 'articles', "#{requested}.r0"))
#       template = File.join(@root, 'src', 'handlers', 'webrick.wtpl')
#       begin
#         [requested == '404' ? 404 : 200, 'text/html', WLang::file_instantiate(template, :current => requested)]
#       rescue Exception => ex
#         puts ex.message
#         puts ex.backtrace.join("\n")
#         back = (ex.respond_to?(:wlang_backtrace) ? ex.wlang_backtrace : ex.backtrace).join("\n")
#         [500, 'text/plain', ex.message << "\n" << back]
#       end
#     end
#   end
#   
# end

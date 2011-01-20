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
post '/leave-a-comment' do
  nick, comment = params["nickname"], params["comment"]
  nick, comment = nick.strip, comment.strip
  from = params["mail"].strip
  from = from.empty? ? "info@revision-zero.org" : from
  if nick.empty? or comment.empty?
    "ko"
  else
    begin
      require 'net/smtp'
      smtp_conn = Net::SMTP.new("localhost", 25)
      smtp_conn.open_timeout = 3
      smtp_conn.start
      smtp_conn.send_message("from: #{nick}\n\n#{comment}", from, "blambeau@gmail.com")
      smtp_conn.finish
    "ok"
  end
end

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

# This serves pages
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
post '/leave-comment' do
  # nick name
  nick = params["nickname"] 
  nick = nick.empty? ? nil : nick
  
  # comment
  comment = params["comment"].strip
  comment = comment.empty? ? nil : comment
  
  # from
  sender = params["mail"].strip
  sender = sender.empty? ? "info@revision-zero.org" : sender
 
  if nick.nil? || comment.nil?
    [200, {'Content-Type' => 'text/plain'}, [ "ko" ]]
  else
    [200, {'Content-Type' => 'text/plain'}, [ "ok" ]]
  end
end

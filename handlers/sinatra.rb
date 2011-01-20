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
  puts params.inspect
  "ok"
end

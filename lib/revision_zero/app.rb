require 'wlang/ext/hash_methodize'
module RevisionZero
  class App < Sinatra::Base
    
    ### Utilities
    
    def self._(file)
      File.expand_path("../../../#{file}", __FILE__)
    end
    
    def _(file)
      self.class._(file)
    end
    
    ### Model
    
    def info
      @info ||= begin
        inf = YAML::load File.read(_('src/articles/writings.yaml'))
        inf.writings.each{|wr|
          wr['src_location'] = _("src/articles/#{wr.identifier}.r0")
        }
        inf
      end
    end
    
    def writings 
      info.writings
    end
    
    def writing(wid)
      if wr = writings.find{|w| w.identifier == wid}
        wr
      else
        not_found
      end
    end

    ### Services
    
    def serve(wid)
      w = writing(wid)
      Templates.html(
        :info      => info,
        :current   => w.identifier,
        :writing   => w,
        :analytics => settings.analytics,
        :keywords  => w.keywords
      )
    end
    
    ### Sinatra rules
    
    set :public, _('public')

    get '/' do
      serve(writings.last.identifier)
    end
    
    get '/rss' do
      content_type "application/rss+xml"
      Templates.rss(:info => info)
    end
    
    get %r{/(\d+)$} do
      ith = writings[params[:captures].first.to_i]
      ith ? serve(ith.identifier) : not_found
    end
    
    get '/:which' do
      serve(params[:which])
    end
    
    set :analytics, Proc.new{ environment == :production }
    
  end # class App
end # module RevisionZero
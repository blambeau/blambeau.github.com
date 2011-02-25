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
      YAML::load File.read(_('src/articles/writings.yaml'))
    end
    
    def writings 
      info.writings
    end
    
    def writing(wid)
      wr = writings.find{|w| w.identifier == wid}
      not_found unless wr
      wr['src_location'] = _("src/articles/#{wr.identifier}.r0")
      wr
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
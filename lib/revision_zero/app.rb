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
    set :analytics, Proc.new{ environment == :production }

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
    
    post '/leave-comment' do
      begin
        require 'logger'
        logger = Logger.new('app.log')
        logger.level = Logger::INFO
      
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
          begin
            Mail.deliver do
                 from(sender)
                   to("blambeau@gmail.com")
              subject("[revision-zero.org] Comment from #{nick || 'anonymous'}")
                 body(comment)
            end
      	    logger.info("Mail from #{sender} (#{nick}) successfully delivered")
            [200, {'Content-Type' => 'text/plain'}, [ "ok" ]]
          rescue Exception => ex
            logger.error "Unable to send mail from #{sender} (#{nick}): #{ex.message}\n#{comment}\n"
            [500, {'Content-Type' => 'text/plain'}, [ "ko" ]]
          end
        end
      rescue Exception => ex
        File.open('app.err', "w"){|io| 
          io << ex.message << "\n"
          io << ex.backtrace.join("\n")
        }
        raise
      end
    end

  end # class App
end # module RevisionZero
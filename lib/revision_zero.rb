#
# This is my blog implementation
#
require "revision_zero/version"
require "revision_zero/loader"
module RevisionZero

  Mail.defaults do
    delivery_method :smtp, { 
     :address   => "localhost",
  	 :port      => 25,
  	 :domain    => 'revision-zero.org',
     :user_name => nil,
     :password  => nil,
  	 :authentication => nil,
  	 :enable_starttls_auto => false 
    }
  end
  
  def self._(file)
    File.expand_path("../../#{file}", __FILE__)
  end
    
  def self.info
    @info ||= begin
      inf = YAML::load File.read(_('src/articles/writings.yaml'))
      writings = inf.writings
      writings.each_with_index{|wr, i|
        wr['src_location'] = _("src/articles/#{wr.identifier}.r0")
        wr['next'] = (writings[i + 1] && writings[i + 1].identifier)
        wr['previous'] = (i != 0 && writings[i - 1].identifier)
      }
      inf
    end
  end
  
  def self.writing(wid)
    info.writings.find{|w| w.identifier == wid}
  end
  
end # module RevisionZero
require "revision_zero/dialect"
require "revision_zero/templates"
require "revision_zero/app"

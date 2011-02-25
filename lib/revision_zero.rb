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
  
end # module RevisionZero
require "revision_zero/dialect"
require "revision_zero/templates"
require "revision_zero/app"

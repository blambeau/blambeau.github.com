require 'fileutils'
module RevisionZero
  module Templates
    
    HTML = {
      :title    => "Revision-Zero.org",
      :keywords => ["computer science", "ruby"]
    }
    
    def _(file)
      File.expand_path("../templates/#{file}", __FILE__)
    end
    
    def cache_get(file)
      basename = File.basename(file)
      target   = _("cache/#{basename}")
      File.exists?(target) ? File.read(target) : nil
    end
    
    def cache_set(file, content)
      basename = File.basename(file)
      target   = _("cache/#{basename}")
      FileUtils.mkdir_p(File.dirname(target))
      File.open(target, 'w'){|io| io << content}
      content
    end
    
    def go(file, context, use_cache)
      if use_cache
        cached = cache_get(file)
        unless cached
          inst = WLang::file_instantiate(file, context)
          cached = cache_set(file, inst)
        end
        cached
      else
        WLang::file_instantiate(file, context)
      end
    end
    
    def html(context = {})
      go(_('html.wtpl'), HTML.merge(context), false)
    end
    
    extend Templates
  end # module Templates 
end # module RevisionZero
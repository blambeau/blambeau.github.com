desc "Cleans the cached file"
task :clean do
  require 'fileutils'
  FileUtils.rm_rf 'lib/revision_zero/templates/cache'
end
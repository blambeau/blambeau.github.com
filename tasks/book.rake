desc "Regenerates the book"
task :book => :clean do
  require 'revision_zero'
  require 'revision_zero/allinone'
  require 'fileutils'
  target = 'public/downloads/revision-zero.html'
  FileUtils.mkdir_p(File.dirname(target))
  File.open(target, 'w'){|io|
    io << RevisionZero::Templates.allinone(
      :css     => css_embed('public/css/style.css'),
      :info    => $info,
      :current => 'book'
    )
  }
end
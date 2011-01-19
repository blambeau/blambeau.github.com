task :generate do
  Process.wait Kernel.spawn("ruby -I. -I../wlang/lib handlers/apache.rb --analytics output/official")
  Process.wait Kernel.spawn("ruby -I. -I../wlang/lib handlers/allinone.rb output/official/downloads/revision-zero.html")
end

task :deploy => :generate do
  puts `cd output/official && git commit -a -m "RevZero regenerated." && git push origin revzero`
  puts `rvm 1.8.7, ruby /usr/bin/aello-invoke revzero`
end
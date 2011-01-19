task :deploy do
  puts `ruby -I../wlang/lib handlers/apache.rb --analytics ../revision-zero`
  puts `ruby -I../wlang/lib handlers/allinone.rb ../revision-zero/downloads/revision-zero.html`
  puts `cd ../revision-zero && git commit -a -m "RevZero regenerated." && git push origin revzero`
  puts `aello-invoke revzero`
end
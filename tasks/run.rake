desc "Runs the sinatra app"
task :run do
  $LOAD_PATH.unshift('lib')
  require "revision_zero"
  ENV['RACK_ENV'] = 'test'
  ENV['REVZERO_CACHE'] = 'false'
  RevisionZero::App.run!
end
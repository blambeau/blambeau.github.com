#!/usr/bin/env rackup
# begin
#   gem "bundler", "~> 1.0"
#   require "bundler"
#   Bundler.setup(:default)
# rescue LoadError => ex
#   puts ex.message
#   abort "Bundler failed to load, (did you run 'gem install bundler' ?)"
# end
ENV['RACK_ENV'] = 'production'
$LOAD_PATH.unshift ::File.expand_path('../lib', __FILE__)
require 'revision_zero'
run RevisionZero::App.new
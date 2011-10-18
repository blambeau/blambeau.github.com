#!/usr/bin/env rackup
ENV['RACK_ENV'] = 'production'
ENV['REVZERO_CACHE'] = 'true'
$LOAD_PATH.unshift ::File.expand_path('../lib', __FILE__)
require 'revision_zero'
run RevisionZero::App.new

#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.join(File.expand_path('..', __dir__), 'app/lib'))

require 'paprika'
module Paprika
  puts Checker.create(ARGV.getopts('', 'checker:')['checker'] || ARGV.first).result
rescue => e
  warn e.message
  exit 1
end

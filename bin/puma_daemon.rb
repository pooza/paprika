#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.join(File.expand_path('..', __dir__), 'app/lib'))
ENV['RAKE'] = nil

require 'paprika'
module Paprika
  PumaDaemon.spawn!(singleton: true)
end

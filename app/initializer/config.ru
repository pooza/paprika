$LOAD_PATH.unshift(File.join(File.expand_path('../..', __dir__), 'app/lib'))

require 'paprika'
run Paprika.rack

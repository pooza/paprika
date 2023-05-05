$LOAD_PATH.unshift(File.join(dir = File.expand_path('../..', __dir__), 'app/lib'))

require 'paprika'
config = Paprika::Config.instance
environment Paprika::Environment.type
workers config['/puma/workers']
threads 0, config['/puma/threads']
port config['/puma/port']
pidfile File.join(dir, config['/puma/pidfile'])
rackup File.join(dir, config['/puma/rackup'])

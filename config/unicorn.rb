listen  ENV['UNICORN_PORT'] || 8001, backlog:  ENV['UNICORN_BACKLOG'] || 100

working_directory File.expand_path('../..', __FILE__)

# What the timeout for killing busy workers is, in seconds
timeout ENV['UNICORN_TIMEOUT'] || 60

# Whether the app should be pre-loaded
preload_app true

# How many worker processes
worker_processes ENV['UNICORN_WORKERS'] || 1

# What to do before we fork a worker
#before_fork do |server, worker|
#  sleep 1
#end

# Where to drop a pidfile
# pid '/home/rack/eviterra/shared/pids/unicorn.pid'
# TODO
pid 'tmp/pids/unicorn.pid'

before_fork do |server,worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end
  Completer.load rescue nil
end

after_fork do |server,worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end

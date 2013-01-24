project_home = ENV['UNICORN_HOME'] || '.'
working_directory project_dir

listen  (ENV['UNICORN_PORT'] || 8001).to_i, backlog: (ENV['UNICORN_BACKLOG'] || 100).to_i


# What the timeout for killing busy workers is, in seconds
timeout (ENV['UNICORN_TIMEOUT'] || 60).to_i

# Whether the app should be pre-loaded
preload_app true

# How many worker processes
worker_processes (ENV['UNICORN_WORKERS'] || 1).to_i

# Where to drop a pidfile
pid project_home + '/tmp/pids/unicorn.pid'

stderr_path project_home + "/log/unicorn.stderr.log"
stdout_path project_home + "/log/unicorn.stdout.log"

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

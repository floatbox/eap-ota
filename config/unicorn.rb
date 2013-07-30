# для дебага нестартующего юникорна:
# RAILS_ENV=production UNICORN_HOME=/home/rack/eviterra/current UNICORN_BACKLOG=1000 UNICORN_WORKERS=80 HOME=/home/rack UNICORN_TIMEOUT=60 bundle exec unicorn -c /home/rack/current/config/unicorn.rb
project_home = ENV['UNICORN_HOME'] || '.'
working_directory project_home
stderr_path project_home + "/log/unicorn.stderr.log"
stdout_path project_home + "/log/unicorn.stdout.log"

listen  (ENV['UNICORN_PORT'] || 8001).to_i, backlog: (ENV['UNICORN_BACKLOG'] || 100).to_i

# What the timeout for killing busy workers is, in seconds
timeout (ENV['UNICORN_TIMEOUT'] || 60).to_i

# Whether the app should be pre-loaded
preload_app true

# How many worker processes
worker_processes (ENV['UNICORN_WORKERS'] || 1).to_i

# Where to drop a pidfile
pid project_home + '/tmp/pids/unicorn.pid'

# блок вызывается в мастере перед форком КАЖДОГО воркера
before_fork do |server,worker|
  server.logger.info "forking in #{Dir.pwd}"
  Completer.preload!
  Commission.preload!
  ActiveRecord::Base.connection.disconnect!

  # graceful shutdown. если все нормально загрузилось, убивает старый юникорн
  old_pid = project_home + '/tmp/pids/unicorn.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server,worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end

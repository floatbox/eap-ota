# для дебага нестартующего юникорна:
# RAILS_ENV=production UNICORN_HOME=/home/rack/eviterra/current UNICORN_BACKLOG=1000 UNICORN_WORKERS=80 HOME=/home/rack UNICORN_TIMEOUT=60 bundle exec unicorn -c /home/rack/current/config/unicorn.rb
project_home = ENV['UNICORN_HOME'] || '.'
working_directory project_home
stderr_path project_home + "/log/unicorn.stderr.log"
stdout_path project_home + "/log/unicorn.stdout.log"

listen  (ENV['UNICORN_PORT'] || 8001).to_i, backlog: (ENV['UNICORN_BACKLOG'] || 100).to_i

# What the timeout for killing busy workers is, in seconds
timeout (ENV['UNICORN_TIMEOUT'] || 600).to_i

# Whether the app should be pre-loaded
preload_app true

# How many worker processes
worker_processes (ENV['UNICORN_WORKERS'] || 1).to_i

# Where to drop a pidfile
pid project_home + '/tmp/pids/unicorn.pid'

# блок вызывается в мастере перед форком КАЖДОГО воркера
before_fork do |server,worker|
  server.logger.info("worker=#{worker.nr} spawning in #{Dir.pwd}")
  Completer.preload!
  Commission.preload!
  ActiveRecord::Base.connection.disconnect!

  # graceful shutdown. если все нормально загрузилось, убивает старый юникорн
  old_pid_file = project_home + '/tmp/pids/unicorn.pid.oldbin'
  if File.exists?(old_pid_file) && server.pid != old_pid_file
    begin
      old_pid = File.read(old_pid_file).to_i
      server.logger.info("sending QUIT to #{old_pid}")
      Process.kill("QUIT", old_pid)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server,worker|
  server.logger.info("worker=#{worker.nr} spawned pid=#{$$}")
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end

before_exec do |server|
  server.logger.info("forked child re-executing...")
  # попытка починить gem reload
  server.logger.info("setting BUNDLE_GEMFILE (was #{ENV['BUNDLE_GEMFILE']})")
  ENV["BUNDLE_GEMFILE"] = project_home + "/Gemfile"
end

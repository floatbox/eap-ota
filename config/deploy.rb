# Load RVM's capistrano plugin.
require "rvm/capistrano"
require "capistrano_colors"

set :rvm_type, :system
# закрепил версию, чтобы не прыгала в продакшне
set :rvm_ruby_string, 'ruby-1.9.3-head'

require 'bundler/capistrano'

# cron tasks
set :whenever_command, "bundle exec whenever"
set :whenever_environment do rails_env end
set :whenever_roles, :daemons
require "whenever/capistrano"

set :scm, :git

set :user, "rack"
set :use_sudo, false

set :deploy_via, :remote_cache
set :copy_exclude, '.git/*'

# если гитхаб ляжет
# то выключить :remote_cache выше и сделать
# set :repository,  "git@team.eviterra.ru:eviterra.git"

set :repository,  "git@github.com:Eviterra/eviterra.git"
# если репозиторий лежит на той же машине
task :localgit do
  set :deploy_via, :copy
  set :repository,  "."
end

# для shared/* папочки для deploy:setup
set :shared_children, %w(log pids system config initializers cache)

# для deploy:migrate
set :rake, 'bundle exec rake'

# для деплоймента ассетов
load 'deploy/assets'

# не делаем touch для public/*, по идее, не помогает с ассетами
set :normalize_asset_timestamps, false

# нужен для нормального форвардинга ключей, соответствующая настройка
# в пользовательском .ssh/config почему-то не читается
# ssh_options[:forward_agent] = true

set :application, "eviterra"

task :staging do
  set :rails_env, 'staging'
  role :app, 'vm1.eviterra.com', 'vm2.eviterra.com'
  role :web, 'vm3.eviterra.com'
  role :daemons, 'vm2.eviterra.com'
  role :db, 'vm1.eviterra.com', :primary => true

  set :rvm_type, :user
  set :rvm_ruby_string, 'ruby-1.9.3-p194'
  set :branch, 'staging'
end

task :eviterra do
  load 'lib/recipes/passenger'
  server 'bender.eviterra.com', :app, :web
  role :db, 'bender.eviterra.com', :primary => true
  role :daemons, 'bender.eviterra.com'
  set :application, "eviterra"
  set :rails_env, 'production'
  set :rvm_type, :system
end

set :deploy_to, "/home/#{user}/#{application}"

namespace :deploy do

  task :symlink_shared_configs do
      run "ln -sf #{shared_path}/config/* #{latest_release}/config/; true"
      run "ln -sf #{shared_path}/initializers/* #{latest_release}/config/initializers/; true"
  end

  task :symlink_persistent_cache do
    run "ln -s #{shared_path}/cache #{latest_release}/tmp/cache"
  end

  task :symlink_completer do
    run "ln -s #{shared_path}/completer.dat #{latest_release}/tmp/completer.dat || echo #{shared_path}/completer.dat does not exist"
  end

  desc <<-DESC
    Checks if there're migrations pending. By default, it runs this in most recently \
    deployed version of the app. However, you can specify a different release \
    via the migrate_target variable, which must be one of :latest (for the \
    default behavior), or :current (for the release indicated by the \
    `current' symlink). Strings will work for those values instead of symbols, \
    too. You can also specify additional environment variables to pass to rake \
    via the migrate_env variable. Finally, you can specify the full path to the \
    rake executable by setting the rake variable. The defaults are:

      set :rake,           "rake"
      set :rails_env,      "production"
      set :migrate_env,    ""
      set :migrate_target, :latest
  DESC
  task :check_for_pending_migrations, :roles => :db, :only => { :primary => true } do
    rake = fetch(:rake, "rake")
    rails_env = fetch(:rails_env, "production")
    migrate_env = fetch(:migrate_env, "")
    migrate_target = fetch(:migrate_target, :latest)

    directory = case migrate_target.to_sym
      when :current then current_path
      when :latest  then current_release
      else raise ArgumentError, "unknown migration target #{migrate_target.inspect}"
      end

    puts "#{migrate_target} => #{directory}"
    run "cd #{directory}; #{rake} RAILS_ENV=#{rails_env} #{migrate_env} db:abort_if_pending_migrations || echo PLEASE DON\\\'T FORGET TO cap deploy:migrate!"
  end

  # daemons

  task :restart_rambler_daemon, :roles => :daemons, :on_no_matching_servers => :continue do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} script/rambler_daemon restart"
  end

  task :start_rambler_daemon, :roles => :daemons, :on_no_matching_servers => :continue do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} script/rambler_daemon start"
  end

  task :stop_rambler_daemon, :roles => :daemons, :on_no_matching_servers => :continue do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} script/rambler_daemon stop"
  end

  task :restart_delayed_job, :roles => :daemons, :on_no_matching_servers => :continue do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} script/delayed_job restart"
  end

  task :start_delayed_job, :roles => :daemons, :on_no_matching_servers => :continue do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} script/delayed_job start"
  end

  task :stop_delayed_job, :roles => :daemons, :on_no_matching_servers => :continue do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} script/delayed_job stop"
  end

  task :restart_services do
    # уже полгода не используем
    # restart_rambler_daemon
    restart_delayed_job
  end

  task :start_services do
    start_rambler_daemon
    start_delayed_job
  end

  task :stop_services do
    stop_rambler_daemon
    stop_delayed_job
  end


  after "deploy:finalize_update", "deploy:symlink_shared_configs"
  after "deploy:finalize_update", "deploy:symlink_persistent_cache"
  after "deploy:finalize_update", "deploy:symlink_completer"
  after "deploy", "deploy:restart_services"
  # after "deploy:update_code", "deploy:check_for_pending_migrations"
  after "deploy:rollback", "deploy:restart_services"

  after "deploy:update", "newrelic:notice_deployment"
end

desc "Edit local config on all servers and restart instances if updated"
task :config do
  require 'tmpdir'
  remote_path = "#{current_path}/config/local/site.yml"
  local_path = Dir.tmpdir + '/' + Dir::Tmpname.make_tmpname(['config-', '.yml'], Process.pid)
  get remote_path, local_path
  if system(ENV['EDITOR'], local_path)
    upload local_path, remote_path
    puts "restarting..."
    deploy.restart
    deploy.restart_services
  else
    puts "aborted."
  end
end


# airbrake stuff
require './config/boot'
require 'airbrake/capistrano'
require 'new_relic/recipes'

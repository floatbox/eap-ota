# Add RVM's lib directory to the load path.
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
# Load RVM's capistrano plugin.
require "rvm/capistrano"
require "capistrano_colors"

# закрепил версию, чтобы не прыгала в продакшне
set :rvm_ruby_string, 'ree-1.8.7-2011.03'

require 'bundler/capistrano'

# cron tasks
set :whenever_command, "bundle exec whenever"
set :whenever_environment do rails_env end
require "whenever/capistrano"

require 'hoptoad_notifier/capistrano'

set :scm, :git

set :user, "rack"
set :use_sudo, false

set :deploy_via, :remote_cache

# если гитхаб ляжет
# то выключить :remote_cache выше и сделать
# set :repository,  "git@team.eviterra.ru:eviterra.git"

set :repository,  "git@github.com:Eviterra/eviterra.git"
# если репозиторий лежит на той же машине
task :localgit do
  set :deploy_via, :copy
  set :repository,  "."
end


set :shared_children, %w(log pids system config initializers cache)

# для deploy:migrate
set :rake, 'bundle exec rake'

# для деплоймента ассетов
load 'deploy/assets'

# нужен для нормального форвардинга ключей, соответствующая настройка
# в пользовательском .ssh/config почему-то не читается
# ssh_options[:forward_agent] = true

task :delta do
  server 'delta.eviterra.com', :app, :web
  role :db, 'delta.eviterra.com', :primary => true
  set :application, "delta"
  set :rails_env, 'delta'
  set :deploy_to, "/home/#{user}/#{application}"
end

task :eviterra do
  server 'eviterra.com', :app, :web
  role :db, 'eviterra.com', :primary => true
  set :application, "eviterra"
  set :rails_env, 'production'
  set :deploy_to, "/home/#{user}/#{application}"
end


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


  after "deploy:finalize_update", "deploy:symlink_shared_configs"
  after "deploy:finalize_update", "deploy:symlink_persistent_cache"
  after "deploy:finalize_update", "deploy:symlink_completer"
  after "deploy:update_code", "deploy:check_for_pending_migrations"
end

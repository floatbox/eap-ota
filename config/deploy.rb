# Add RVM's lib directory to the load path.
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
# Load RVM's capistrano plugin.
require "rvm/capistrano"
# Set it to the ruby + gemset of your app, e.g:
set :rvm_ruby_string, 'ree'

require 'bundler/capistrano'
require 'hoptoad_notifier/capistrano'

set :scm, :git

set :rails_env, 'production'
set :user, "rack"
set :use_sudo, false

set :deploy_via, :remote_cache
# если репозиторий лежит на той же машине
#set :deploy_via, :copy
#set :repository,  "."

set :repository,  "git@team.eviterra.ru:eviterra.git"


set :shared_children, %w(log pids system config initializers cache)

# для deploy:migrate
set :rake, 'bundle exec rake'

# нужен для нормального форвардинга ключей, соответствующая настройка
# в пользовательском .ssh/config почему-то не читается
ssh_options[:forward_agent] = true

task :delta do
  server 'delta.eviterra.com', :app, :web
  role :db, 'delta.eviterra.com', :primary => true
  set :application, "delta"
  set :deploy_to, "/home/#{user}/#{application}"
end

task :eviterra do
  server 'eviterra.com', :app, :web
  role :db, 'eviterra.com', :primary => true
  set :application, "eviterra"
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

  after "deploy:finalize_update", "deploy:symlink_shared_configs"
  after "deploy:finalize_update", "deploy:symlink_persistent_cache"
  after "deploy:finalize_update", "deploy:symlink_completer"
end

require 'bundler/capistrano'
require 'hoptoad_notifier/capistrano'

set :application, "delta"

set :scm, :git

set :rails_env, 'production'
set :user, "rack"
set :use_sudo, false

set :deploy_to, "/home/#{user}/#{application}"
set :srv, "delta.eviterra.com"

set :deploy_via, :remote_cache
# если репозиторий лежит на той же машине
#set :deploy_via, :copy
#set :repository,  "."

set :repository,  "git@team.eviterra.ru:eviterra.git"

role :app, srv
role :web, srv
role :db, srv, :primary => true


set :shared_children, %w(log pids system config initializers cache)

# для deploy:migrate
set :rake, 'bundle exec rake'

# нужен для нормального форвардинга ключей, соответствующая настройка
# в пользовательском .ssh/config почему-то не читается
ssh_options[:forward_agent] = true

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

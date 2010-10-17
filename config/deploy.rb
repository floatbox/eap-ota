require 'bundler/capistrano'

set :application, "gamma"

set :scm, :git

set :rails_env, 'production'
set :user, "rack"
set :use_sudo, false

set :deploy_to, "/home/#{user}/#{application}"
set :srv, "team.eviterra.ru"

# если репозиторий лежит на той же машине
#set :deploy_via, :copy
#set :repository,  "."

set :repository,  "git@team.eviterra.ru:eviterra.git"

role :app, srv
role :web, srv
role :db, srv, :primary => true


set :shared_children, %w(log pids system config initializers)

# нужен для нормального форвардинга ключей, соответствующая настройка
# в пользовательском .ssh/config почему-то не читается
ssh_options[:forward_agent] = true

namespace :deploy do
  task :symlink_shared_configs do
      run "ln -sf #{shared_path}/config/* #{latest_release}/config/; true"
      run "ln -sf #{shared_path}/initializers/* #{latest_release}/config/initializers/; true"
  end
  after "deploy:finalize_update", "deploy:symlink_shared_configs"
end

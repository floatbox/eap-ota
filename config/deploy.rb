# Load RVM's capistrano plugin.
require "rvm/capistrano"
require "capistrano_colors"
require "hipchat/capistrano"

require 'riemann/client'

# интеграция с hipchat
set :hipchat_token, 'de492e09eba5f6cc6cf340f480734d'
set :hipchat_room_name, "cave"
#set :hipchat_announce, false # notify users?

set :rvm_type, :system
# закрепил версию, чтобы не прыгала в продакшне
#set :rvm_ruby_string, 'ruby-1.9.3-p327-falcon'

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
set :repository,  "git@github.com:Eviterra/eviterra.git"
# если репозиторий лежит на той же машине
task :localgit do
  set :deploy_via, :copy
  set :repository,  "."
end

# для shared/* папочки для deploy:setup
# не работает, когда use_sudo true
set :shared_children, %w(log pids system config initializers cache local)

# для deploy:migrate
set :rake, 'bundle exec rake'

# для деплоймента ассетов
load 'deploy/assets'

# не делаем touch для public/*, по идее, не помогает с ассетами
set :normalize_asset_timestamps, false

# нужен для нормального форвардинга ключей, соответствующая настройка
# в пользовательском .ssh/config почему-то не читается
ssh_options[:forward_agent] = true

set :application, "eviterra"

task :demo do
load 'lib/recipes/unicorn'
  set :rails_env, 'demo'
  role :app, 'vm12.eviterra.com'
  role :web, 'vm12.eviterra.com'
  role :db, 'vm12.eviterra.com', :primary => true
  role :daemons, 'vm12.eviterra.com'
end

task :staging do
load 'lib/recipes/unicorn'
  set :rails_env, 'staging'
  role :app, 'vm1.eviterra.com', 'vm2.eviterra.com'
  role :web, 'vm3.eviterra.com', 'vm1.eviterra.com', 'vm2.eviterra.com'
  role :db, 'vm1.eviterra.com', :primary => true
  role :daemons, 'vm1.eviterra.com'
  #set :branch, 'staging'
end

task :eviterra do
load 'lib/recipes/unicorn'
  set :rails_env, 'production'
  role :app, 'flexo.eviterra.com', 'bender.eviterra.com', 'deck.eviterra.com', 'calculon.eviterra.com'
  role :web, 'hermes.eviterra.com', 'deck.eviterra.com', 'vm11.eviterra.com'
  role :db, 'deck.eviterra.com', :primary => true
  role :daemons, 'deck.eviterra.com'
end

set :deploy_to, "/home/#{user}/#{application}"

namespace :deploy do

  task :symlink_shared_configs do
      run "ln -sf #{shared_path}/config/* #{latest_release}/config/; true"
      run "ln -sf #{shared_path}/initializers/* #{latest_release}/config/initializers/; true"
  end

  # по каким-то причинам assets:precompile все равно грохает его содержимое
  # разобраться
  task :symlink_persistent_cache do
    run "ln -s #{shared_path}/cache #{latest_release}/tmp/cache"
  end

  task :symlink_db_local do
    run "rm -rf #{latest_release}/db/local"
    run "ln -sf #{shared_path}/local #{latest_release}/db/local"
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

  desc <<-DESC
    Regenerates completer. If you need to create completer.dat on a new machine, \
    you probably want to run

      cap deploy:update_code deploy:completer
  DESC
  task :completer do
    rake = fetch(:rake, "rake")
    rails_env = fetch(:rails_env, "production")
    directory = current_release
    run "cd #{directory}; #{rake} RAILS_ENV=#{rails_env} completer:regen"
  end

  # daemons
  DJ_QUEUES = %W{notifications autoticketing subscriptions}

  task :restart_delayed_job, :roles => :daemons, :on_no_matching_servers => :continue do
    DJ_QUEUES.each { |queue| run "sudo /usr/bin/sv -w 60 restart /etc/service/delayed_job_#{queue}" }
  end

  task :start_delayed_job, :roles => :daemons, :on_no_matching_servers => :continue do
    DJ_QUEUES.each { |queue| run "sudo /usr/bin/sv start /etc/service/delayed_job_#{queue}" }
  end

  task :stop_delayed_job, :roles => :daemons, :on_no_matching_servers => :continue do
    DJ_QUEUES.each { |queue| run "sudo /usr/bin/sv -w 60 stop /etc/service/delayed_job_#{queue}" }
  end

  task :restart_services do
    restart_delayed_job
  end

  task :start_services do
    start_delayed_job
  end

  task :stop_services do
    stop_delayed_job
  end

  task :notify_riemann do
    r = Riemann::Client.new host: '198.199.124.27'
    event = {
      service: 'deploy',
      host: 'all-hosts',
      tags: ['gauge', fetch(:rails_env, 'production')],
      metric: 1,
      time: Time.now.to_i
    }

    r << event
  end

  after "deploy:finalize_update", "deploy:symlink_shared_configs"
  after "deploy:finalize_update", "deploy:symlink_persistent_cache"
  after "deploy:finalize_update", "deploy:symlink_db_local"
  after "deploy", "deploy:restart_services"
  # after "deploy:update_code", "deploy:check_for_pending_migrations"
  after "deploy:rollback", "deploy:restart_services"

  after "deploy:update", "newrelic:notice_deployment"
  after "deploy:update", "deploy:notify_riemann"

  task :fix_i18njs, :roles => :web do
    run "cd #{latest_release} && touch tmp/i18n-js.cache"
  end
  before "deploy:assets:precompile", "deploy:fix_i18njs"
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


require './config/boot'
require 'rollbar/capistrano'
set :rollbar_token, 'b810757b1a234503a1611a223d097ad4'
require 'new_relic/recipes'

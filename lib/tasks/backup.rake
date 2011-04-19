namespace :db do
  desc "Backup the database to a file. Options: FILE=base_dir RAILS_ENV=production" 
  task :backup => :environment do
    backup_file = ENV['FILE'] || 'tmp/backup.sql.gz'
    FileUtils.makedirs(File.dirname(backup_file))
    db_config = ActiveRecord::Base.configurations[Rails.env]
    password_opt = "-p#{db_config['password']}" if db_config['password']
    sh "mysqldump -u #{db_config['username']} #{password_opt} #{db_config['database']} | gzip -c > #{backup_file}"
    puts "Created backup: #{backup_file}"
  end
end

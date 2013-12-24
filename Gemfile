source 'https://rubygems.org'
gem 'rails', '3.2.12'

gem 'jquery-rails', '~> 2.0.2'
gem 'i18n-js', :git => 'https://github.com/fnando/i18n-js.git'
group :assets do
  #gem 'therubyracer'
  gem "uglifier"
  gem 'sass-rails'
  gem 'coffee-script-source', '~> 1.4.0'
  gem 'coffee-rails'
  gem 'handlebars_assets'
end

# консолька вместо IRB
# если убрать в группу :development, не грузит больше в rails c
# возможно, отжирает память и ресурсы
gem 'pry-rails'

gem 'commands'

# Deploy with Capistrano
group :deployment do
  gem 'capistrano'
  gem 'rvm-capistrano'
  gem 'capistrano_colors'
end

# логгеры. выберу только один
gem 'lumberjack'
gem 'lumberjack_syslog_device'
gem 'lumberjack_multi-device'
gem 'riemann-client', require: false
# для импорта zip файлов
gem 'zip'
gem 'money'
gem 'central_bank_of_russia'
gem 'kaminari'
gem 'daemons'
gem 'nokogiri'
gem 'sax-machine', :git => 'https://github.com/gregwebs/sax-machine.git'
gem 'yajl-ruby'
gem 'whenever', :require => false
gem 'cucumber'
gem 'handsoap'
gem 'curb'
# нужен для typhoeus driver у handsoap
# gem 'typhoeus'
gem 'crack'
gem "every"
gem "memoize"
gem 'morpher_inflect'
gem 'russian'
#gem 'graticule'
gem 'mysql2'
gem 'paper_trail'
gem 'geo_ip'
gem 'rollbar'
gem 'newrelic_rpm'
# gem 'rpm_contrib'
gem 'mongoid'
gem 'bson_ext'
gem 'mobile-fu'
gem "devise", "~> 2.2.8"
gem 'virtus'
gem 'sendgrid'
gem 'hipchat'
gem 'attribute-defaults'
gem 'redis'

gem 'mongo-rails-instrumentation', :git => 'git://github.com/Eviterra/mongo-rails-instrumentation.git'

gem 'haml'
gem 'hpricot', require: false

gem 'activeadmin'
gem 'cancan'
gem 'draper'
gem 'typus', :git => 'https://github.com/Eviterra/typus.git'
gem "flot-rails"
gem 'delayed_job_mongoid'

# appservers
gem 'thin', :require => false
gem 'unicorn', :require => false

group :development do
  gem 'yard'
  gem 'yard-activerecord'
  gem 'zeus'
  gem 'letter_opener'
end

group :test do
  gem 'rspec-rails'
  gem 'cucumber-rails', :require => false
  gem 'webrat'
  gem 'factory_girl_rails'

  gem 'guard'
  gem 'terminal-notifier-guard', require: false
  gem 'libnotify', require: false
  gem 'guard-spork'
  gem 'guard-rspec'
  # gem 'guard-rails-assets'
  gem 'capybara'
  gem 'spork'
  gem 'database_cleaner'

  gem 'vcr'
  gem 'webmock'
  # тестирование завтрашних комиссий
  gem 'timecop'
end


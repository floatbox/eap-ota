source 'http://rubygems.org'
gem 'rails', '3.1.1'

gem 'jquery-rails'
group :assets do
  gem "uglifier", ">= 1.0.3"
  gem 'sass-rails', "~> 3.1.4"
  gem 'coffee-rails', "~> 3.1.1"
end


# Deploy with Capistrano
group :deployment do
  gem 'capistrano'
  gem 'capistrano_colors'
end

gem 'yajl-ruby'
gem 'rake'
gem 'whenever', :require => false
gem 'i18n'
gem 'cucumber'
gem 'handsoap', :git => 'git://github.com/codesnik/handsoap.git', :branch => 'fixing_async_again'
gem 'curb'
gem 'typhoeus'
gem 'nokogiri'
gem 'crack'
gem "every"
gem "memoize"
gem 'morpher_inflect'
gem 'russian', :git => 'https://github.com/codesnik/russian.git'
#gem 'graticule'
gem 'mysql2'
gem 'paper_trail'
gem 'tzinfo'
gem 'geo_ip'
gem 'therubyracer'
gem 'airbrake'
gem 'newrelic_rpm'
gem 'mongoid'
gem 'bson_ext'
gem 'qu-mongo'
gem 'SystemTimer', :platforms => :ruby_18

gem 'ya2yaml'

#gem 'eviterra-instrumentation', :path => '../eviterra-instrumentation'
gem 'eviterra-instrumentation', :git => 'git://github.com/codesnik/eviterra-instrumentation.git'
gem 'mongo-rails-instrumentation'

gem 'haml'

gem 'typus'
#gem 'typus', :git => 'https://github.com/typus/typus.git' #, :branch => "3-1-stable"
gem 'fastercsv', :platforms => :ruby_18

gem 'trashed', :git => 'https://github.com/codesnik/trashed.git'

group :development do
  gem 'mongrel', :platforms => :ruby_18
end
gem 'passenger', :group => :production

group :test do
  gem 'rspec-rails'
  gem 'cucumber-rails'
  gem 'webrat'
  gem 'factory_girl_rails'

  gem 'guard'
  gem 'rb-inotify', :require => false
  gem 'rb-fsevent', :require => false
  gem 'rb-fchange', :require => false
  gem 'growl' # for OSX
  gem 'libnotify' # for linux
  gem 'guard-spork'
  gem 'guard-rspec'
  # gem 'guard-rails-assets'
  gem 'capybara'
  gem 'spork'
  gem 'database_cleaner'

  gem 'vcr'
  gem 'webmock'
end

group :console do
  gem 'wirble'
  gem 'looksee'
  gem 'awesome_print'
  gem 'interactive_editor'
end

group :debug do
  gem 'ruby-debug', :platforms => :ruby_18
  gem 'ruby-debug19', :require => 'ruby-debug', :platforms => :ruby_19
end

group :profiling do
  gem 'ruby-prof'
end


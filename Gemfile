source 'http://rubygems.org'
gem 'rails', '3.2.1'

gem 'jquery-rails'
group :assets do
  #gem 'therubyracer'
  gem "uglifier"
  gem 'sass-rails'
  gem 'coffee-rails'
end

# консолька вместо IRB
gem 'pry-rails'
gem 'pry-doc', require: false
# расцветка строки ввода. убрал, ибо глушат полезные хоткеи
# gem 'pry-coolline' #, :git => 'https://github.com/pry/pry-coolline.git'
gem 'pry-editline', require: false

# Deploy with Capistrano
group :deployment do
  gem 'capistrano'
  gem 'rvm-capistrano'
  gem 'capistrano_colors'
end

gem 'evergreen', :require => 'evergreen/rails', :group => :development

gem 'money'
gem 'kaminari'
gem 'daemons'
gem 'nokogiri'
gem 'yajl-ruby'
gem 'whenever', :require => false
gem 'cucumber'
gem 'handsoap', :git => 'git://github.com/codesnik/handsoap.git', :branch => 'fixing_async_again'
gem 'curb'
gem 'typhoeus'
gem 'crack'
gem "every"
gem "memoize"
gem 'morpher_inflect'
gem 'russian'
#gem 'graticule'
gem 'mysql2'
gem 'paper_trail'
gem 'geo_ip'
gem 'airbrake'
gem 'newrelic_rpm'
gem 'rpm_contrib'
gem 'mongoid'
gem 'bson_ext'
gem 'SystemTimer', :platforms => :ruby_18
gem 'ya2yaml', :platforms => :ruby_18
gem 'mobile-fu'

#gem 'eviterra-instrumentation', :path => '../eviterra-instrumentation'
gem 'eviterra-instrumentation', :git => 'git://github.com/codesnik/eviterra-instrumentation.git'
gem 'mongo-rails-instrumentation'

gem 'haml'
gem 'hpricot', require: false

gem 'typus', :git => 'https://github.com/Eviterra/typus.git'
gem "flot-rails"
gem 'delayed_job_mongoid'

group :development do
  gem 'thin'
end
gem 'passenger', :group => :production

group :test do
  gem 'rspec-rails'
  gem 'cucumber-rails', :require => false
  gem 'webrat'
  gem 'factory_girl_rails'

  gem 'guard'
  gem 'rb-inotify', :require => false
  gem 'rb-fsevent', :require => false
  gem 'rb-fchange', :require => false
  gem 'growl' # for OSX
  # for linux
  gem 'libnotify', :require => false
  gem 'guard-spork'
  gem 'guard-rspec'
  # gem 'guard-rails-assets'
  gem 'capybara'
  gem 'spork'
  gem 'database_cleaner'

  gem 'vcr'
  gem 'webmock'
end

group :debug do
  gem 'ruby-debug', :platforms => :ruby_18
  gem 'ruby-debug19', :require => 'ruby-debug', :platforms => :ruby_19
end

group :profiling do
  gem 'ruby-prof'
end


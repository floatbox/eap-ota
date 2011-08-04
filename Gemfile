source 'http://rubygems.org'
gem 'rails', '3.1.0.rc5'



# Deploy with Capistrano
group :deployment do
  gem 'capistrano'
end

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
gem 'russian'
gem 'graticule'
gem 'mysql2'
gem 'tzinfo'
gem 'geo_ip'
gem 'hoptoad_notifier'
gem 'newrelic_rpm'
gem 'mongoid'
gem 'bson_ext'
gem 'SystemTimer'

#gem 'eviterra-instrumentation', :path => '../eviterra-instrumentation'
gem 'eviterra-instrumentation', :git => 'git://github.com/codesnik/eviterra-instrumentation.git'

gem 'haml'

#gem 'typus'
gem 'typus', :git => 'https://github.com/typus/typus.git', :branch => "3-1-unstable"

gem 'trashed', :git => 'https://github.com/37signals/trashed.git'

group :development do
  gem 'mongrel' if RUBY_VERSION < "1.9.0"
end

group :test, :development do
  gem 'rspec-rails'
  gem 'cucumber-rails'
  gem 'autotest'
end

group :test do
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
  gem 'ruby-debug' if RUBY_VERSION < "1.9.0"
end

group :profiling do
  gem 'ruby-prof'
end


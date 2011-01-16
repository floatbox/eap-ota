source 'http://rubygems.org'
gem 'rails', '3.0.3'



# Deploy with Capistrano
group :deployment do
  gem 'capistrano'
end

gem 'i18n'
gem 'cucumber'
gem 'handsoap'
gem 'curb'
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

gem 'haml'

gem 'typus', :git => 'https://github.com/fesplugas/typus.git'
#gem 'typus', :path => '../typus'

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


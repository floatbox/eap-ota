# encoding: utf-8
Eviterra::Application.configure do

  config.after_initialize do
    # тут можно понизить или повысить level у отдельных логгеров
    Moped.logger = ForwardLogging.new(Rails.logger, Logger::INFO)
    # ActiveRecord::Base.logger = ForwardLogging.new(Rails.logger, Logger::INFO)
    # ActionController::Base.logger = ForwardLogging.new(Rails.logger, Logger::WARN)
  end

  # Settings specified here will take precedence over those in config/application.rb

  # новая фича в rails 3.2. Возможные варианты - :uuid, :subdomain, :pid, :remote_ip
  # добавляет в лог указанные аттрибуты для каждого запроса
  # config.log_tags = [:uuid]

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true #временно
  config.cache_store = :file_store, Rails.root + "tmp/cache/"

  # Don't care if the mailer can't send
  #config.action_mailer.delivery_method = :sendmail
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.raise_delivery_errors = false
  #config.action_mailer.default_content_type = "text/html"
  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log
  config.action_mailer.default_url_options = { :host => Conf.site.host, :protocol => Conf.site.ssl ? 'https' : 'http' }

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  # config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.1

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  # для правок жаваскрипта и css можно поставить true
  config.assets.debug = false

  # закомментировать, если будет проблема с ассетами.
  config.assets.logger = false

  # перечитываем конфиг перед каждым реквестом.
  # не все опции работают без рестарта!
  config.middleware.use 'Conf::Reloader'
end

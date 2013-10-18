# encoding: utf-8
Eviterra::Application.configure do

  config.after_initialize do
    # тут можно понизить или повысить level у отдельных логгеров
    # Moped.logger = ForwardLogging.new(Rails.logger, Logger::DEBUG)
  end

  # # изменения в логгере: lumberjack + syslog
  # # закомменчено до проверки на staging
  # template = lambda do |entry| 
  #   # насильно проставляем progname = 'eviterra' в Lumberjack::LogEntry
  #   entry.progname = 'eviterra'
  #   # тут же можно выставить severity или другие аттрибуты
  #   # не меняем формат лога
  #   "#{entry.message}"
  # end

  # # композитный девайс для Lumberjack
  # devices = [
  #   Lumberjack::SyslogDevice.new(:template => template),
  #   Lumberjack::Device::LogFile.new(Rails.root + "log/#{Rails.env}.log",
  #     template: template)
  # ]
  # multi_device = Lumberjack::MultiDevice.new(devices)

  # config.logger = ActiveSupport::TaggedLogging.new(
  #   Lumberjack::Logger.new(multi_device)
  # )

  # новая фича в rails 3.2. Возможные варианты - :uuid, :subdomain, :pid, :remote_ip
  # добавляет в лог указанные аттрибуты для каждого запроса
  config.log_tags = [:uuid, :remote_ip]

  # Settings specified here will take precedence over those in config/application.rb

  # здесь, а не в application.rb, для удобства дебага
  config.filter_parameters += [:card]

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  config.action_mailer.delivery_method = :smtp
  # config.action_mailer.smtp_settings = {
  #   :enable_starttls_auto => true,
  #   :address => 'smtp.gmail.com',
  #   :port => 587,
  #   :domain => "eviterra.com",
  #   :authentication => :plain,
  #   :user_name => "no-reply@eviterra.com",
  #   :password => "production_mailer"
  # }
  config.action_mailer.smtp_settings = {
    :enable_starttls_auto => true,
    :address => 'smtp.sendgrid.net',
    :port => 587,
    :domain => "eviterra.com",
    :authentication => :plain,
    :user_name => "eviterra",
    :password => "flywithme"
  }
  config.action_mailer.default_url_options = { :host => Conf.site.host, :protocol => Conf.site.ssl ? 'https' : 'http' }

  config.action_controller.perform_caching = true
  config.cache_store = :file_store, Rails.root + "tmp/cache/"

  # Specifies the header that your server uses for sending files
  # (comment out if your front-end server doesn't support this)
  config.action_dispatch.x_sendfile_header = "X-Sendfile" # Use 'X-Accel-Redirect' for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug
  config.colorize_logging = false

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # config.logger = ActiveSupport::TaggedLogging.new(OldBufferedLogger.new('log/production.log', OldBufferedLogger::INFO))

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Don't fallback to assets pipeline if a precompiled asset is missed
  # config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Compress JavaScripts and CSS
  # кажется, нельзя убрать при выключенном .debug. обобщенный файл все равно сжат
  config.assets.compress = true

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = nil

  # автоматически включает мониторинг GC в newrelic, когда включен GC::Profiler
  # ручку в конфиге не делал
  # закомментить, чтобы выключить
  GC::Profiler.enable
end


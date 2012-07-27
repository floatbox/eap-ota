# encoding: utf-8
Eviterra::Application.configure do
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


  config.action_controller.perform_caching = true
  config.cache_store = :file_store, Rails.root + "tmp/cache/"

  # Specifies the header that your server uses for sending files
  # (comment out if your front-end server doesn't support this)
  config.action_dispatch.x_sendfile_header = "X-Sendfile" # Use 'X-Accel-Redirect' for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  config.logger = ActiveSupport::TaggedLogging.new(OldBufferedLogger.new('log/production.log'), OldBufferedLogger::INFO)

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
  config.assets.compress = true

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5
end

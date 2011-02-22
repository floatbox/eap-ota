Eviterra::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = true #временно
  config.cache_store = :file_store, Rails.root + "tmp/cache/"

  # Don't care if the mailer can't send
  #config.action_mailer.raise_delivery_errors = false

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :enable_starttls_auto => true,
    :address => 'smtp.gmail.com',
    :port => 587,
    :domain => "eviterra.com",
    :authentication => :plain,
    :user_name => "no-reply@eviterra.com",
    :password => "delta_mailer"
  }
  config.action_mailer.default_content_type = "text/html"
  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exceptions instead of rendering exception templates
  # config.action_dispatch.show_exceptions = false
end


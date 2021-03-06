require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Eviterra
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)

    # Rails 4 backport:
    # убрать после миграции на rails 4
    config.paths.add "app/controllers/concerns", eager_load: true
    config.paths.add "app/models/concerns",      eager_load: true

    config.paths.add "app/jobs",                 eager_load: true
    config.paths.add "app/validators",           eager_load: true
    config.paths.add "app/serializers",          eager_load: true
    config.paths.add "app/flows",                eager_load: true
    config.paths.add "app/presenters",           eager_load: true

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Moscow'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    I18n.config.enforce_available_locales = false
    config.i18n.default_locale = :ru

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    config.middleware.use "CodeStash::Middleware"

    # X-Forwarded-For парсится слишком поздно, в логах светился ip балансера зачем-то.
    config.middleware.delete "ActionDispatch::RemoteIp"
    config.middleware.insert_before "Rails::Rack::Logger", "ActionDispatch::RemoteIp"

    config.generators do |g|
      g.orm :active_record
    end

    initializer 'action_dispatch.eviterra_exceptions', :before => 'action_dispatch.configure' do
    # config.action_dispatch.rescue_responses.update 'ArgumentError' => :bad_request
      config.action_dispatch.rescue_responses.update 'Mongoid::Errors::DocumentNotFound' => :not_found
      config.action_dispatch.rescue_responses.update 'BSON::InvalidObjectId' => :not_found
    end

    # Settings in config/environments/* take precedence over those specified here.

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    # config.active_record.whitelist_attributes = true

    config.active_record.identity_map = true

    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
    config.assets.precompile += %w( home.js home.css common.js common.css typus/application.css typus/application.js )

    # попытка решить проблему с mtime на nil
    # не помогло
    # config.assets.initialize_on_precompile = true

    # Не знаю, как это вопхать в инициализатор
    console do
      # помечаем изменения, сделанные из консоли:
      PaperTrail.whodunnit = 'dev@eviterra.com'
      PaperTrail.controller_info = {:done => 'console'}

      Object.send :include, AdminLink
    end

    require 'money/bank/zero_exchange'
    Money.default_bank = Money::Bank::ZeroExchange.new
    Money.default_currency = Money::Currency.new("RUB")

  end
end


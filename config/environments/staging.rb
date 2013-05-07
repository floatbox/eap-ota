# encoding: utf-8
# так же, как в production
require File.expand_path('../production.rb', __FILE__)
Eviterra::Application.configure do
  # оверрайды - сюда
#  config.action_mailer.delivery_method = :test
  config.action_mailer.delivery_method = :sendmail
  config.action_mailer.default_url_options = { :host => 'staging.eviterra.com' }
end

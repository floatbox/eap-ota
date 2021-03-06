require 'rollbar/rails'
Rollbar.configure do |config|
  config.access_token = 'b810757b1a234503a1611a223d097ad4'

  if Rails.env.test? || Rails.env.development?
    config.enabled = false
  end

  config.exception_level_filters.merge!('ActionController::RoutingError' => 'ignore')

  # By default, Rollbar will try to call the `current_user` controller method
  # to fetch the logged-in user object, and then call that object's `id`,
  # `username`, and `email` methods to fetch those properties. To customize:
  # config.person_method = "my_current_user"
  # config.person_id_method = "my_id"
  # config.person_username_method = "my_username"
  # config.person_email_method = "my_email"

  config.use_async = true
end

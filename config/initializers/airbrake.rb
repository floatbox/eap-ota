Airbrake.configure do |config|
  config.api_key = 'a4ca32b7fb71874b9f4c5f38ff2c6da2'
  config.user_attributes = [:email]
  # раскомментировать, чтобы дебажить airbrake в development mode
  # config.development_environments = []
end

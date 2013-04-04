Airbrake.configure do |config|
  config.api_key = 'a4ca32b7fb71874b9f4c5f38ff2c6da2'
  config.js_api_key = '2b98a8cf6039754404a090dc00a745f5'
  config.user_attributes = [:email]
  # раскомментировать, чтобы дебажить airbrake не на продакшне
  # config.development_environments = []
end

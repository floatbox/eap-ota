RSpec.configure do |config|
  # прогонять только тесты с :focus => true
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  # останавливаться после первой ошибки
  # config.fail_fast = true
end

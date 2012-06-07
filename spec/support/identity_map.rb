RSpec.configure do |config|
  ActiveRecord::IdentityMap.enabled = true
  config.after :each do
    ActiveRecord::IdentityMap.clear
  end
end

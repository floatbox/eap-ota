# добавляет методы build, create, stub(?),  attributes_for и т.п. в спеки
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end

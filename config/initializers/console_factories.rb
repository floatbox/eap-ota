# метод для консоли, который делает доступными:
# Factory(:payture_charge),
# build(:order)
# create(:order, :pnr_number => '234DDK')
# people = build_list(:person, 5)
def factories!
  require 'factory_girl'
  require './spec/factories'
  extend FactoryGirl::Syntax::Methods
end

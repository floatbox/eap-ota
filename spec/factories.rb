# documentation: https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md
FactoryGirl.define do

  factory :order do
    pnr_number {|x| "XXXX#{x}" }
  end

end

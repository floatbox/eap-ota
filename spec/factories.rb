# documentation: https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md
FactoryGirl.define do

  sequence :pnr_number do |n|
    "XXX%03d" % n
  end

  sequence :first_name do |n|
    names = ["ALEXEY", "NIKOLAI", "ELENA", "BORIS"]
    names[n % names.size]
  end

  # если сделать другое их количество, то они пересекаться не будут!
  sequence :last_name do |x|
    last_names = ["IVANOV", "PETROV", "SKRIPCHENKO", "AVDEEV", "BARANOV"]
    last_names[n % last_names.size]
  end

  factory :order do
    pnr_number
  end

  factory :person do
    first_name
    last_name
  end

  factory :payture_charge do
    order

    # не работает! попробовать сделать его с помощью
    # after_create do |payture_charge, proxy| ...

    #factory :charged_payture_charge do
    #  status 'charged'
    #end
  end

  factory :payture_refund do
    association :charge, :factory => :payture_charge
  end

  factory :cash_charge do
    order
  end

  factory :cash_refund do
    association :charge, :factory => :cash_charge
  end

end

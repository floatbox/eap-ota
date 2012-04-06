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
  sequence :last_name do |n|
    last_names = ["IVANOV", "PETROV", "SKRIPCHENKO", "AVDEEV", "BARANOV"]
    last_names[n % last_names.size]
  end

  factory :order do
    pnr_number
  end

  factory :person do
    first_name
    last_name

    factory :adult_person do
      birthday {20.years.ago}
    end
    factory :child_person do
      birthday {8.years.ago}
      infant_or_child 'c'
    end
    factory :infant_person do
      birthday {2.months.ago}
      infant_or_child 'i'
    end
  end

  factory :payture_charge do
    order

    # пока не годится для build - не проставляет status
    factory :charged_payture_charge do
      after_create do |payture_charge, proxy|
        payture_charge.update_attributes status: 'charged'
      end
    end
  end

  factory :payture_refund do
    association :charge, :factory => :charged_payture_charge

    # пока не годится для build - не проставляет status
    factory :charged_payture_refund do
      after_create do |payture_refund, proxy|
        payture_refund.update_attributes status: 'charged'
      end
    end
  end

  factory :cash_charge do
    order
  end

  factory :cash_refund do
    association :charge, :factory => :cash_charge
  end

end

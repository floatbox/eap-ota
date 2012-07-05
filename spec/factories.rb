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
    fix_price true
    price_with_payment_commission 3000
  end

  factory :person do
    first_name
    last_name
    birthday {20.years.ago}

    trait :child do
      birthday {8.years.ago}
      infant_or_child 'c'
    end
    trait :infant do
      birthday {2.months.ago}
      infant_or_child 'i'
    end
  end

  factory :ticket do
    order
    sequence :number do |n|
      "2345#{n}"
    end
    code '123'
    price_fare 1000
    price_tax 100
    kind 'ticket'
    status 'ticketed'

    trait :direct do
      office_id 'MOWR228FA'
    end
    trait :aviacenter do
      office_id 'MOWR2233B'
    end
  end

  factory :refund, :class => Ticket do
    order
    price_fare 1000
    price_tax 100
    status 'processed'
    comment 'blablabla'
    kind 'refund'
  end

  factory :payture_charge do
    order

    # пока не годится для build - не проставляет status
    trait :charged do
      after_create do |payture_charge, proxy|
        payture_charge.update_attributes status: 'charged'
      end
    end
    factory :charged_payture_charge, :traits => [:charged]
  end

  factory :payture_refund do
    association :charge, :factory => :charged_payture_charge

    # пока не годится для build - не проставляет status
    trait :charged do
      after_create do |payture_refund, proxy|
        payture_refund.update_attributes status: 'charged'
      end
    end
  end

  factory :cash_charge do
    order

    # пока не годится для build - не проставляет status
    trait :charged do
      after_create do |payture_charge, proxy|
        payture_charge.update_attributes status: 'charged'
      end
    end
  end

  factory :cash_refund do
    association :charge, :factory => :cash_charge
  end

  # amadeus sessions
  sequence :amadeus_session_token do |n|
    token = 'TESTAAAAAA'
    n.times { token.next! }
    token
  end

  factory :amadeus_session_ar_store, class: 'Amadeus::Session::ARStore' do
    token { FactoryGirl.generate(:amadeus_session_token) }
    seq 2
    office { 'TEST_DEFAULT_OFFICE' }

    trait :booked do
      booked true
    end

    trait :stale do
      updated_at 30.minutes.ago
    end
  end

  factory :amadeus_session_mongo_store, class: 'Amadeus::Session::MongoStore' do
    token { FactoryGirl.generate(:amadeus_session_token) }
    seq 2
    office { 'TEST_DEFAULT_OFFICE' }

    trait :booked do
      booked true
    end

    trait :stale do
      after_create do |session, proxy|
        session.updated_at = 30.minutes.ago
        session.save_without_touching
      end
    end
  end

end

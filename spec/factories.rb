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
    email 'example@gmail.com'
  end

  factory :stored_flight do
    marketing_carrier_iata 'SU'
    departure_iata 'SVO'
    arrival_iata 'LED'
    dept_date Date.today + 1.week
    flight_number 1
  end

  factory :person do
    first_name
    last_name
    birthday {20.years.ago}

    trait :child do
      birthday {8.years.ago}
      child true
    end
    trait :infant do
      birthday {6.months.ago}
      infant true
    end
  end

  factory :ticket do
    order
    sequence :number do |n|
      "2345#{n}"
    end
    code '123'
    original_price_fare '1000 RUB'
    original_price_tax '100 RUB'
    kind 'ticket'
    status 'ticketed'
    ticketed_date (Date.today - 2.days)

    trait :direct do
      office_id 'MOWR228FA'
    end
    trait :aviacenter do
      office_id 'MOWR2233B'
    end
  end

  factory :refund, :class => Ticket do
    order
    original_price_fare '1000 RUB'
    original_price_tax '100 RUB'
    ticketed_date (Date.today - 1.days)
    status 'processed'
    comment 'blablabla'
    kind 'refund'
  end

  #
  # платежи
  #

  # FIXME как-то сделать неглобальным
  trait :charged do
    after :create do |payment|
      payment.update_attributes status: 'charged'
    end
  end

  factory :payu_charge do
    order
  end

  factory :payu_refund do
    association :charge, factory: [:payu_charge, :charged]
  end

  factory :payture_charge do
    order
    endpoint_name 'payture_alfa'
  end

  factory :payture_refund do
    association :charge, factory: [:payture_charge, :charged]
    endpoint_name 'payture_alfa'
  end

  factory :cash_charge do
    order
  end

  factory :cash_refund do
    association :charge, factory: :cash_charge
  end

  #
  # amadeus sessions
  #

  sequence :amadeus_session_token do |n|
    token = 'TESTAAAAAA'
    n.times { token.next! }
    token
  end

  factory :amadeus_session_ar_store, class: 'Amadeus::Session::ARStore' do
    token { generate(:amadeus_session_token) }
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
    token { generate(:amadeus_session_token) }
    seq 2
    office { 'TEST_DEFAULT_OFFICE' }

    trait :booked do
      booked true
    end

    trait :stale do
      after :create do |session|
        session.updated_at = 30.minutes.ago
        session.save_without_touching
      end
    end
  end

  factory :partner do
    enabled true
    token '1234'

    trait :disabled do
      enabled false
    end

    trait :anonymous do
      token ''
    end

    trait :limit_20 do
      suggested_limit 20
    end
  end

  factory :context do
    deck_user nil
    robot false
    partner FactoryGirl.build(:partner, :anonymous)

    initialize_with do
      builder = ContextBuilder.new
      builder.partner = partner
      builder.robot = robot
      builder.deck_user = deck_user
      builder.build!
    end

    trait :deck_user do
      deck_user Deck::User.new
    end

    trait :robot do
      robot true
    end

    trait :partner do
      partner FactoryGirl.build(:partner)
    end

    trait :disabled_partner do
      partner FactoryGirl.build(:partner, :disabled)
    end

    trait :limited_partner do
      partner FactoryGirl.build(:partner, :limit_20)
    end
  end

  factory :amadeus_session_redis_store, class: 'Amadeus::Session::RedisStore' do
    token { generate(:amadeus_session_token) }
    seq 2
    office { 'TEST_DEFAULT_OFFICE' }

    trait :booked do
      after :create do |session|
        key = Amadeus::Session::RedisStore.free_by_office(session.office)
        # убираем последний запушенный токен
        token = Amadeus::Session::RedisStore.redis.lpop(key)
        key = Amadeus::Session::RedisStore.by_token(token)
        Amadeus::Session::RedisStore.redis.del(key)
      end
    end

    trait :stale do
      after :create do |session|
        key = Amadeus::Session::RedisStore.free_by_office(session.office)
        # убираем последний запушенный токен
        token = Amadeus::Session::RedisStore.redis.lpop(key)
        key = Amadeus::Session::RedisStore.by_token(token)
        Amadeus::Session::RedisStore.redis.del(key)
      end
    end

  end
end


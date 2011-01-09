class OrderData < ActiveRecord::BaseWithoutTable
  column :email
  column :phone
  has_many :people
  attr_writer :card
  attr_accessor :recommendation
  attr_accessor :pnr_number
  attr_accessor :people_count
  attr_accessor :number
  attr_accessor :order_id
  attr_accessor :variant_id #нужен при восстановлении формы по урлу

  # убить? используется в pnr_add_multi_elements
  attr_accessor :action

  validates_format_of :email, :with => 
  /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => "Некорректный email"
  validates_presence_of :email, :phone
  validates_format_of :phone, :with => /^[\d \+\-\(\)]+$/

  def card
    @card || Billing::CreditCard.new
  end


  def adults
    people && (people.sort_by(&:birthday)[0..(people_count[:adults]-1)])
  end

  def children
    s_pos = people_count[:adults]
    e_pos = people_count[:adults] + people_count[:children]-1
    (people && (people_count[:children] > 0) && (people.sort_by(&:birthday)[s_pos..e_pos])) || []
  end

  def infants
    s_pos = people_count[:adults] + people_count[:children]
    (people && (people_count[:infants] > 0) && (people.sort_by(&:birthday)[s_pos..-1])) || []
  end

  def errors_hash
    res = {}
    res['order[email]'] = errors[:email] if errors[:email]
    res['order[phone]'] = errors[:phone] if errors[:phone]
    people.each_with_index{|p, i|
      unless p.valid?
        p.errors.each{|e,v|
          res["person[#{i}][#{e}]"] = v
        }
      end
    }
    unless card.valid?
      card.errors.each{|e,v|
        res["card[#{e}]"] = v
      }
    end
    res
  end
  
  
  def hash
    [recommendation, people_count, people, card].hash
  end
  
  def store_to_cache
    self.number ||= ShortUrl.generate_url(self.hash)
    Cache.write("order_data", number, self)
  end
  
  def self.get_from_cache(cache_number)
    require 'segment'
    require 'variant'
    require 'flight'
    require 'recommendation'
    require 'person'
    Cache.read("order_data", cache_number)
  end
  
  def variant
    recommendation && recommendation.variants.first
  end
  
  def init_people
    self.people = (1..(people_count[:adults].to_i + people_count[:children].to_i + people_count[:infants].to_i)).map {|n|
        Person.new
    }
  end

  def seat_count
    people_count[:adults] + people_count[:children]
  end

  def validate
    errors.add :card, 'Отсутствуют данные карты' unless card
    errors.add :card, 'Некорректные данные карты' if card && !card.valid?
  end

  def set_flight_date_for_childen_and_infants
    last_date = recommendation.flights.last.dept_date
    children.each{|c|
      c.flight_date = last_date
      c.infant_or_child = 'c'
    }
    infants.each{|i|
      i.flight_date = last_date
      i.infant_or_child = 'i'
    }
  end
  
  def block_money
    self.order_id = 'am' + self.pnr_number
    unless Payture.new.block(recommendation.price_with_payment_commission, card, :order_id => order_id)
      card.errors.add :number, "не удалось провести платеж"
      self.errors.add :card, 'Платеж не прошел'
      return
    else
      return true
    end
  end

  def commission
    recommendation.commission
  end

  def validating_carrier
    recommendation.validating_carrier.iata
  end

  #4 следующих метода нужно для нормального pnr_add_multi_elements
  def flights
    []
  end

  def debug
    false
  end

  # по идее, как-то должно быть перенесено прямо в lib/amadeus
  def create_booking
    amadeus = Amadeus::Service.new(:book => true)
    amadeus.air_sell_from_recommendation(
      :segments => recommendation.variants[0].segments, :people_count => seat_count
    ).bang!

    add_multi_elements = amadeus.pnr_add_multi_elements(self).bang!
    if self.pnr_number = add_multi_elements.pnr_number
      set_people_numbers(add_multi_elements.passengers)
      amadeus.pnr_commit_really_hard do
        fares_count =
          amadeus.fare_price_pnr_with_booking_class(:validating_carrier => validating_carrier).bang!.fares_count
        # FIXME среагировать на отсутствие маски
        amadeus.ticket_create_tst_from_pricing(:fares_count => fares_count).bang!
      end

      # FIXME Payture глючит
      # if block_money
      if true
        amadeus.pnr_commit_really_hard do
          # FIXME среагировать на различие в цене
          add_passport_data(amadeus)
          amadeus.give_permission_to_offices(
            Amadeus::Session::TICKETING,
            Amadeus::Session::WORKING
          )
          amadeus.pnr_archive(seat_count)
        end
        #amadeus.queue_place_pnr(:number => pnr_number)
        Order.create(:order_data => self)

        # обилечивание
        #Amadeus::Service.issue_ticket(pnr_number)

        PnrMailer.notification(email, self.pnr_number).deliver if email
        return pnr_number
      else
        # FIXME добавить какой-то индикатор ошибки блокировки денег
        amadeus.pnr_cancel
        return
      end
    else
      amadeus.pnr_ignore
      errors.add :pnr_number, 'Ошибка при создании PNR' 
      return
    end
  ensure
    amadeus.session.destroy
  end

  def add_passport_data(amadeus)
    validating_carrier_code = recommendation.validating_carrier.iata
    (adults + children).each do |person|
      amadeus.cmd( "SRDOCS#{validating_carrier_code}HK1-P-#{person.nationality.alpha3}-#{person.passport}-#{person.nationality.alpha3}-#{person.birthday.strftime('%d%b%y').upcase}-#{person.sex.upcase}-#{person.smart_document_expiration_date.strftime('%d%b%y').upcase}-#{person.last_name}-#{person.first_name}-H/P#{person.number_in_amadeus}")
      amadeus.cmd("SR FOID #{validating_carrier_code} HK1-PP#{person.passport}/P#{person.number_in_amadeus}")
      amadeus.cmd("FE #{validating_carrier_code} ONLY PSPT #{person.passport}/P#{person.number_in_amadeus}")
      amadeus.cmd("FFN#{person.bonuscard_type}-#{person.bonuscard_number}/P#{person.number_in_amadeus}") if person.bonus_present
    end
    infants.each_with_index do |person, i|
      amadeus.cmd( "SRDOCS#{validating_carrier_code}HK1-P-#{person.nationality.alpha3}-#{person.passport}-#{person.nationality.alpha3}-#{person.birthday.strftime('%d%b%y').upcase}-#{person.sex.upcase}I-#{person.smart_document_expiration_date.strftime('%d%b%y').upcase}-#{person.last_name}-#{person.first_name}-H/P#{person.number_in_amadeus}")
      amadeus.cmd("FE INF #{validating_carrier_code} ONLY PSPT #{person.passport}/P#{person.number_in_amadeus}")
    end
  end

  def set_people_numbers(returned_people)
    returned_people.each do |p|
      people.detect do |person|
        person.last_name.upcase == p.last_name && person.first_name.upcase == p.first_name
      end.number_in_amadeus = p.number_in_amadeus
    end
  end

  def full_info
    res = ''
    people.every.coded.join("\n")
  end
  
  def self.create_sample_booking(cache_key)
    order = OrderData.get_from_cache(cache_key)
    order.email = 'email@example.com'
    order.phone = '12345678'
    order.people_count = {:infants => 1, :children => 1, :adults => 1}
    order.people = [Person.new(
      :first_name => 'Ivan',
      :last_name => 'ZAdult',
      :birthday => Date.today - 20.years,
      :document_expiration_date => Date.today + 1.year,
      :passport => '999999999',
      :nationality_id => 1,
      :sex => 'm',
      :bonus_present => true,
      :bonuscard_type => 'SU',
      :bonuscard_number => '345643'
    ),
    Person.new(
      :first_name => 'Masha',
      :last_name => 'Infant',
      :birthday => Date.today - 1.years,
      :document_expiration_date => Date.today + 1.year,
      :passport => '88888888',
      :nationality_id => 1,
      :sex => 'f'
    ),
    Person.new(
      :first_name => 'Masha',
      :last_name => 'Child',
      :birthday => Date.today - 10.years,
      :document_expiration_date => Date.today + 1.year,
      :passport => '77777777',
      :nationality_id => 1,
      :sex => 'f'
    )]
    order.card = Payture.test_card
    order.create_booking
  end
end

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
  validates_format_of :email, :with => 
  /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => "Некорректный email"
  validates_presence_of :email, :phone
  validates_format_of :phone, :with => /^[\d -\(\)]+$/

  def card
    @card || Billing::CreditCard.new()
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
    Rails.cache.write("order_data#{self.number}", self)
  end
  
  def self.get_from_cache(cache_number)
    require 'segment'
    require 'variant'
    require 'flight'
    require 'recommendation'
    require 'person'
    Rails.cache.read('order_data'+ cache_number)
  end
  
  def variant
    recommendation && recommendation.variants.first
  end
  
  def init_people
    self.people = (1..(people_count[:adults].to_i + people_count[:children].to_i + people_count[:infants].to_i)).map {|n|
        Person.new
    }
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
    self.order_id = 'rh' + hash.to_s + Time.now.sec.to_s
    result = Payture.new.block(recommendation.price_with_payment_commission, card, :order_id => order_id)
    if result["Success"] != "True"
      card.errors.add :number, ("не удалось провести платеж (#{result["ErrCode"]})" )
      self.errors.add :card, 'Платеж не прошел'
      return nil
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

  def end_transact
    false
  end

  def ignore
    false
  end

  def create_booking
    amadeus = Amadeus::Service.new(:book => true)
    air_sfr_xml = amadeus.air_sell_from_recommendation(
      :segments => recommendation.variants[0].segments, :people_count => (people_count[:adults] + people_count[:children])
    )
    doc = amadeus.pnr_add_multi_elements(self)
    self.pnr_number = doc.xpath('//r:controlNumber').to_s
    
    if self.pnr_number
      add_passport_data(amadeus)
      amadeus.fare_price_pnr_with_booking_class
      amadeus.ticket_create_tst_from_pricing
      amadeus.pnr_add_multi_elements(PNRForm.new(:end_transact => true))
      amadeus.queue_place_pnr(:number => pnr_number)
      Order.create(:order_data => self)
      PnrMailer.deliver_pnr_notification(email, self.pnr_number) if email
      return pnr_number
    else
      amadeus.pnr_add_multi_elements(PNRForm.new(:end_transact => true))
      errors.add :pnr_number, 'Ошибка при создании PNR' 
      return nil
    end
  ensure
    amadeus.session.destroy
  end

  def add_passport_data(amadeus)
    validating_carrier_code = recommendation.validating_carrier.iata
    (adults + children).each_with_index do |person, i|
      amadeus.cmd( "SRDOCS#{validating_carrier_code}HK1-P-#{person.nationality.alpha3}-#{person.passport}-#{person.nationality.alpha3}-#{person.birthday.strftime('%d%b%y').upcase}-#{person.sex.upcase}-#{person.document_expiration_date.strftime('%d%b%y').upcase}-#{person.last_name}-#{person.first_name}-H/P#{i+1}")
      amadeus.cmd("SR FOID #{validating_carrier_code} HK1-PP#{person.passport}/P#{i+1}")
      amadeus.cmd("FE #{validating_carrier_code} ONLY PSPT #{person.passport}/P#{i+1}")
    end
  end
  
  def self.create_sample_booking
    order = OrderData.get_from_cache('xglG7R')
    order.email = 'email@example.com'
    order.phone = '12345678'
    order.people_count = {:infants => 1, :children => 0, :adults => 1}
    order.people = [Person.new(
      :first_name => 'Ivan',
      :last_name => 'Ivanov',
      :birthday => Date.today - 20.years,
      :document_expiration_date => Date.today + 1.year,
      :passport => '123232323',
      :nationality_id => 1,
      :sex => 'm'
    ),
    Person.new(
      :first_name => 'Masha',
      :last_name => 'Ivanova',
      :birthday => Date.today - 1.years,
      :document_expiration_date => Date.today + 1.year,
      :passport => '5556565',
      :nationality_id => 1,
      :sex => 'f'
    )]
    order.create_booking
  end
end

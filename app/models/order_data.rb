class OrderData < ActiveRecord::BaseWithoutTable
  column :email
  column :phone
  has_many :people
  attr_writer :card
  attr_accessor :recommendation
  attr_accessor :pnr_number
  attr_accessor :people_count
  attr_accessor :number
  validates_format_of :email, :with => 
  /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => "Некорректный email"
  
  def card
    @card || Billing::CreditCard.new()
  end
  
  def hash
    [recommendation, people_count].hash
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
  
  
  def create_booking()
    order_id = 'rh' + hash.to_s + Time.now.sec.to_s
    result = Payture.new.block(recommendation.price_with_payment_commission, card, :order_id => order_id)
    if result["Success"] != "True"
      card.errors.add :number, ("не удалось провести платеж (#{result["ErrCode"]})" )
      return nil
    else
      amadeus = Amadeus.new(:book => true)
      air_sfr_xml = amadeus.soap_action('Air_SellFromRecommendation',
        :segments => recommendation.variants[0].segments, :people_count => people.size
      )
      
      doc = amadeus.pnr_add_multi_elements(PNRForm.new(
        :flights => [],
        :people => people,
        :phone => '1236767',
        :email => email,
        :validating_carrier => recommendation.validating_carrier.iata
      ))
      self.pnr_number = doc.xpath('//r:controlNumber').to_s
      
      if self.pnr_number
        amadeus.soap_action('Fare_PricePNRWithBookingClass')
        amadeus.soap_action('Ticket_CreateTSTFromPricing')
        amadeus.pnr_add_multi_elements(PNRForm.new(:end_transact => true))
        amadeus.soap_action('Queue_PlacePNR', :number => pnr_number)
        Order.create(:order_data => self)
        PnrMailer.deliver_pnr_notification(email, self.pnr_number) if email
        amadeus.session.destroy
        return pnr_number
      else
        errors.add :pnr_number, 'Ошибка при создании PNR' 
        return nil
      end
    end
  end
end
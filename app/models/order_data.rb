class OrderData < ActiveRecord::BaseWithoutTable
  column :email
  column :phone
  has_many :people
  attr_writer :card
  attr_accessor :recommendation
  #attr_accessor :people
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
end
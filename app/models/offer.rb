class Offer
  attr_accessor :segments
  attr_accessor :company
  attr_accessor :hotel
  attr_accessor :id
  attr_accessor :duration
  attr_accessor :persons
  attr_accessor :flight_price

  def as_json options={}
    {
      :id => id,
      :company => company,
      :segments => segments,
      :hotel => hotel,
      :duration => duration,
      :persons => persons,
      :hotel_price => hotel_price,
      :flight_price => flight_price,
      :layovers => layovers,
      :price => price
    }
  end

  def company
    segments.first.marketing_carrier
  end
  
  def price
    hotel_price + flight_price
  end

  def hotel_price
    Price.new 0 #hotel ? hotel.price * duration * persons : Price.new(0)
  end

  def flight_price
    Price.new(@flight_price)
  end
    
  def city
    segments.first ? segments.first.arrival.city : hotel.city
  end

  def country
    city.country
  end

  def layovers
    segments.map(&:layovers_count).max
  end

  def initialize keys={}
    self.id = object_id
    keys.each do |attr, value|
      send "#{attr}=", value
    end
  end

end

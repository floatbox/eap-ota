class Variant

  attr_accessor :id,
    :segments

  def initialize keys={}
    self.id = object_id
    keys.each do |attr, value|
      send "#{attr}=", value
    end
  end
  
  def flight_codes
    segments.every.flights.flatten.every.flight_code
  end

end

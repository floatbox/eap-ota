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

  def common_carrier
    (segments.every.marketing_carrier_name.uniq.length == 1) && segments.first.marketing_carrier
  end

  def common_layovers
    segments.map{|s| s.layovers.every.iata.sort}.uniq.length == 1
  end
end


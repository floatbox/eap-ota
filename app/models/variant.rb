class Variant

  attr_accessor :id,
    :segments

  def initialize keys={}
    self.id = object_id
    keys.each do |attr, value|
      send "#{attr}=", value
    end
  end

  def summary
    {:airlines => segments.map{|s| s.flights.every.operating_carrier_iata}.flatten.uniq,
     :planes => segments.map{|s| s.flights.every.equipment_type_iata}.flatten.uniq,
     :arrival_day_parts => segments.every.arrival_day_part,
     :departure_day_parts => segments.every.departure_day_part,
     :arrival_airports => segments.every.arrival_iata,
     :departure_airports => segments.every.departure_iata
    }
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

  def total_duration
    segments.sum(&:total_duration)
  end
end


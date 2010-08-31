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
    result = {
     :airlines => segments.map{|s| s.flights.every.operating_carrier_iata}.flatten.uniq,
     :planes => segments.map{|s| s.flights.every.equipment_type_iata}.flatten.uniq,
     :departures => segments.map {|segment| segment.departure_time },
     :duration => segments.sum(&:total_duration)
    }
    segments.each_with_index do |segment, i|
      result['dpt_time_' + i.to_s] = segment.departure_day_part
      result['arv_time_' + i.to_s] = segment.arrival_day_part
      result['dpt_airport_' + i.to_s] = segment.departure_iata
      result['arv_airport_' + i.to_s] = segment.arrival_iata
    end
    result
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


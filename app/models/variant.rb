class Variant

  include KeyValueInit

  attr_accessor :segments

  def flights
    segments.sum(&:flights)
  end

  def summary
    result = {
      :airlines => flights.every.operating_carrier_iata.uniq,
      :planes => flights.every.equipment_type_iata.uniq,
      :departures => segments.every.departure_time,
      :duration => segments.sum(&:total_duration),
      :cities => segments.map{|s| s.flights[1..-1].map{|f| f.departure.city.iata}}.flatten.uniq,
      :layovers => segments.map{|s| s.flights.size}.max - 1,
      :flights => flights.size
    }
    segments.each_with_index do |segment, i|
      result['dpt_city_' + i.to_s] = segment.departure.city.iata
      result['arv_city_' + i.to_s] = segment.arrival.city.iata
      result['dpt_time_' + i.to_s] = segment.departure_day_part
      result['arv_time_' + i.to_s] = segment.arrival_day_part
      result['dpt_airport_' + i.to_s] = segment.departure_iata
      result['arv_airport_' + i.to_s] = segment.arrival_iata
    end
    result
  end
  
  def flight_codes(booking_classes)
    result = []
    i = 0
    segments.each_with_index {|s, s_i|
      s.flights.each{|f|
        result << f.flight_code(booking_classes[i], s_i)
        i += 1
        }
      }
    result
  end

  def common_carrier
    segments.every.marketing_carrier_name.uniq.one? && segments.first.marketing_carrier
  end

  # задизаблен в единственной вьюшке, где использовался. убить?
  def common_layovers?
    segments.map{|s| s.layovers.every.iata.sort}.uniq.one?
  end

  def total_duration
    segments.sum(&:total_duration)
  end

  # comparison, uniquiness, etc.
  def signature
    segments
  end

  def hash
    signature.hash
  end

  def eql?(b)
    signature.eql?(b.signature)
  end

end


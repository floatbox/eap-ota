# encoding: utf-8
class Variant

  include KeyValueInit

  attr_accessor :segments

  def flights
    segments.sum(&:flights)
  end

  def summary
    # FIXME carriers для фильтров - operating carrier. ok?
    result = {
      :carriers => flights.every.operating_carrier_iata.uniq,
      :planes => flights.every.equipment_type_iata.uniq,
      :departures => segments.every.departure_time,
      :duration => segments.sum(&:total_duration),
      :cities => segments.map{|s| s.flights[1..-1].map{|f| f.departure.city.iata}}.flatten.uniq,
      :flights => flights.size
    }
    flights_amount = segments.map{|s| s.flights.size}.max
    if flights_amount == 1
      result['layovers'] = 0
    else
      if segments.map{|s| s.layover_durations }.flatten.max < 121
        result['layovers'] = [flights_amount, 1]
      else
        result['layovers'] = flights_amount
      end
    end
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

  # маршрут в виде 'SVX-CDG-SVX'
  def route
    waypoints = city_iatas.dup
    from = waypoints.shift
    to = waypoints.pop
    ([from] + waypoints.each_slice(2).map { |a, b| a == b ? a : "#{a} #{b}" } + [to]).join('-')
  end

  # можно оптимальнее, наверное
  def city_iatas
    airport_iatas.collect { |iata| Airport[iata].city.iata }
  end

  def airport_iatas
    flights.collect {|f| [f.departure_iata, f.arrival_iata] }.flatten
  end

  def country_iatas
    city_iatas.collect { |iata| City[iata].country.iata }
  end

  def marketing_carriers
    flights.every.marketing_carrier.uniq
  end

  def marketing_carrier_iatas
    flights.every.marketing_carrier_iata.uniq
  end

  def operating_carriers
    flights.every.operating_carrier.uniq
  end

  def operating_carrier_iatas
    flights.every.operating_carrier_iata.uniq
  end

  def common_carrier
    marketing_carriers.one? && marketing_carriers.first
  end

  # задизаблен в единственной вьюшке, где использовался. убить?
  # FIXME - говорит ли, что пересадки одинаковые, если во втором сегменте
  # не было пересадок?
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


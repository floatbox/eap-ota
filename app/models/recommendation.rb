class Recommendation

  include KeyValueInit

  attr_accessor :variants, :price_fare, :price_tax, :additional_info, :validating_carrier_iata, :cabins, :booking_classes, :source

  def validating_carrier
    validating_carrier_iata && Airline[validating_carrier_iata]
  end

  def price_total
    price_fare + price_tax + price_markup
  end

  def price_with_payment_commission
    price_total + price_payment
  end

  def price_payment
    (price_total * 0.028).ceil
  end

  def price_tax_and_markup
    price_tax + price_markup
  end

  def segments
    variants.sum(&:segments)
  end

  def flights
    segments.sum(&:flights)
  end

  def layovers?
    segments.any?(&:layovers?)
  end

  def sellable?
    segments.map(&:marketing_carrier).all? &:aviacentr
  end

  def ground?
    flights.any? {|f| %W(train bus).include?(f.equipment_type.engine_type) }
  end

  def minimal_duration
    variants.map(&:total_duration).min
  end

  def self.cheap recs
    recs.select(&:sellable?).min_by(&:price_total)
  end

  def self.fast recs
    recs.select(&:sellable?).min_by(&:minimal_duration)
  end

  def self.merge left, right
    # работает только пока signature не учитывает sources
    merged = left | right
    (merged - left).each {|r| r.source = 'right' }
    (merged - right).each {|r| r.source = 'left' }
    merged
  end

  def self.load_from_cache(recommendation_number)
    # shouldn be neccessary, no?
    require 'segment'
    require 'variant'
    require 'flight'
    Rails.cache.read('recommendation'+ recommendation_number)
  end

  def self.store_to_cache(recommendation_number, recommendation)
    Rails.cache.write("recommendation#{recommendation_number}", recommendation)
  end


  def variants_by_duration
    variants.sort_by(&:total_duration)
  end

  def commission
    @commission ||= Commission.find_for(self)
  end

  def price_share
    if commission
      commission.share(price_fare)
    else
      0
    end
  end

  # надеюсь, никто его не дернет до выставления всех остальных параметров
  def price_markup
    ajust_markup! if @price_markup.nil?
    @price_markup
  end

  def ajust_markup!
    # если меньше 350 рублей, то три процента сверху
    if (price_share) < 350
      @price_markup = ((price_fare + price_tax) * 0.03).to_i
    else
      @price_markup = 0
    end
  end

  def summary
    result = {
      :price => price_total,
      :airline => segments.first.marketing_carrier_name,
      :layovers => variants.first.segments.map{|s| s.flights.size}.max,
    }
    variants.first.segments.each_with_index do |segment, i|
      result['dpt_city_' + i.to_s] = segment.departure.city.case_from.gsub(/ /, '&nbsp;')
      result['arv_city_' + i.to_s] = segment.arrival.city.case_to.gsub(/ /, '&nbsp;')
    end
    result 
  end

  # comparison, uniquiness, etc.
  def signature
    [validating_carrier_iata, price_fare, price_tax, variants]
  end

  def hash
    signature.hash
  end

  def eql?(b)
    signature.eql?(b.signature)
  end
  
  def self.check_price_and_avaliability(flight_codes, people_counts)
    flights = flight_codes.map do |flight_code|
      Flight.from_flight_code flight_code
    end
    segments = []
    flights.each do |fl|
      if segments.blank? || segments.length <= fl.segment_number.to_i
        segments << Segment.new(:flights => [fl])
      else
        segments.last.flights << fl
      end
    end
    variant = Variant.new(:segments => segments)
    recommendation = Recommendation.new(:variants => [variant])
    recommendation.booking_classes = variant.flights.every.class_of_service
    xml = Amadeus.fare_informative_pricing_without_pnr(:flights => flights, :people_counts => people_counts)
    price_total = 0
    price_fare = 0
    # FIXME почему то амадеус возвращает цену для одного человека, даже если указано несколько
    xml.xpath('//r:pricingGroupLevelGroup').each do |pg|
      passengers_in_group = pg.xpath('r:numberOfPax/r:segmentControlDetails/r:numberOfUnits').to_i
      price_total += pg.xpath('r:fareInfoGroup/r:fareAmount/r:otherMonetaryDetails[r:typeQualifier="712"][r:currency="RUB"]/r:amount').to_s.to_i * passengers_in_group
      price_fare += pg.xpath('r:fareInfoGroup/r:fareAmount/r:otherMonetaryDetails[r:typeQualifier="E"][r:currency="RUB"]/r:amount').to_s.to_i * passengers_in_group
    end
    # FIXME не очень надежный признак
    return nil if price_total == 0
    recommendation.price_fare = price_fare
    recommendation.price_tax = price_total - price_fare

    # FIXME сломается, когда появятся инфанты
    amadeus = Amadeus.new(:book => true)
    air_sfr_xml = amadeus.air_sell_from_recommendation(:segments => segments, :people_count => people_counts.values.sum)
    amadeus.session.destroy
    #FIXME нужно разобраться со statusCode - когда все хорошо, а когда - нет
    return nil if air_sfr_xml.xpath('//r:segmentInformation/r:actionDetails/r:statusCode').every.to_s.uniq != ['OK']
    air_sfr_xml.xpath('//r:itineraryDetails').each_with_index {|s, i|
      parse_flights(s, segments[i])
    }
    recommendation
  end
  
  def self.parse_flights(fs, segment)
    fs.xpath('r:segmentInformation').each_with_index {|fl, i|
      flight = segment.flights[i]
      #flight.marketing_carrier_iata ||= fl.xpath("r:flightDetails/r:companyDetails/r:marketingCompany").to_s
      flight.departure_term = fl.xpath("r:apdSegment/r:departureStationInfo/r:terminal").to_s
      flight.arrival_term = fl.xpath("r:apdSegment/r:arrivalStationInfo/r:terminal").to_s
      if fl.xpath("r:flightDetails/r:flightDate/r:arrivalDate").present?
        flight.arrival_date = fl.xpath("r:flightDetails/r:flightDate/r:arrivalDate").to_s
      elsif fl.xpath("r:flightDetails/r:flightDate/r:dateVariation").present?
        flight.arrival_date = (DateTime.strptime( flight.departure_date, '%d%m%y' ) + 1.day).strftime('%d%m%y')
      else
        flight.arrival_date = flight.departure_date
      end
      flight.arrival_time = fl.xpath("r:flightDetails/r:flightDate/r:arrivalTime").to_s
      flight.arrival_time = '0' + flight.arrival_time if flight.arrival_time.length < 4
      flight.departure_time = fl.xpath("r:flightDetails/r:flightDate/r:departureTime").to_s
      flight.departure_time = '0' + flight.departure_time if flight.departure_time.length < 4
      flight.equipment_type_iata = fl.xpath("r:apdSegment/r:legDetails/r:equipment").to_s
    }
  end

  def cabins_except selected_cabin
    selected_cabin = 'Y' if selected_cabin.nil?
    dcabins = cabins.map {|c|
      cabin = (c == 'F' || c == 'C') ? c : 'Y'
      cabin == selected_cabin ? nil : cabin
    }
    fcounter = 0
    variants.first.segments.map {|s|
        fcabins = dcabins[fcounter, s.flights.length]
        fcounter += s.flights.length
        common = fcabins.uniq
        common.length == 1 ? common : fcabins
    }
  end

  # FIXME порнография какая-то. чего так сложно?
  def self.summary recs, locations
    airlines = []
    planes = []
    cities = []
    departure_airports = []
    arrival_airports = []
    departure_times = []
    arrival_times = []
    segments_amount = recs[0].variants[0].segments.length
    segments_amount.times {|i|
      departure_airports[i] = []
      arrival_airports[i] = []
      departure_times[i] = []
      arrival_times[i] = []
    }
    recs.each {|r|
      r.variants.each{|v|
        summary = v.summary
        airlines += summary[:airlines]
        planes += summary[:planes]
        cities += summary[:cities]
        v.segments.length.times {|i|
          departure_airports[i] << summary['dpt_airport_' + i.to_s]
          arrival_airports[i] << summary['arv_airport_' + i.to_s]
          departure_times[i] << summary['dpt_time_' + i.to_s]
          arrival_times[i] << summary['arv_time_' + i.to_s]
        }
      }
    }
    result = {
      :airlines => airlines.uniq.map{|a| {:v => a, :t => Airline[a].name}}.sort_by{|a| a[:t] },
      :planes => planes.uniq.map{|a| {:v => a, :t => Airplane[a].name}}.sort_by{|a| a[:t] },
      :cities => cities.uniq.map{|c| {:v => c, :t => City[c].name}}.sort_by{|a| a[:t] },
      :segments => segments_amount,
      :locations => locations
    }
    departure_airports.each_with_index {|airports, i|
      result['dpt_airport_' + i.to_s] = airports.uniq.map{|airport| {:v => airport, :t => Airport[airport].name} }.sort_by{|a| a[:t] }
    }
    arrival_airports.each_with_index {|airports, i|
      result['arv_airport_' + i.to_s] = airports.uniq.map{|airport| {:v => airport, :t => Airport[airport].name} }.sort_by{|a| a[:t] }
    }
    time_titles = ['ночь', 'утро', 'день', 'вечер']
    departure_times.each_with_index {|dpt_times, i|
      result['dpt_time_' + i.to_s] = dpt_times.uniq.sort.map{|dt| {:v => dt, :t => time_titles[dt]} }
    }
    arrival_times.each_with_index {|arv_times, i|
      result['arv_time_' + i.to_s] = arv_times.uniq.sort.map{|at| {:v => at, :t => time_titles[at]} }
    }
    result
  end
end

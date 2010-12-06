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

  # FIXME константу комиссии засунуть куда-нибудь в lib/payture
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
    validating_carrier.consolidator
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
      result['dpt_location_' + i.to_s] = segment.departure.city.case_from.gsub(/ /, '&nbsp;')
      result['arv_location_' + i.to_s] = segment.arrival.city.case_to.gsub(/ /, '&nbsp;')
    end
    result 
  end

  # comparison, uniquiness, etc.
  def signature
    [validating_carrier_iata, price_fare, price_tax, variants, booking_classes]
  end

  def self.corrected recs
    #объединяем эквивалентные варианты
    recs.each_with_object([]) do |r, result|
      unless r.try_to_merge_with_prev_recommendations result
        result << r
      end
    end
  end

  def try_to_merge_with_prev_recommendations (recommendations)
    return if recommendations.blank? || recommendations.last.price_total != price_total
    recommendations.reverse.each do |r|
      return if r.price_total != self.price_total
      if groupable_with? r
        r.variants += r.variants
        return true
      end
    end
  end

  def groupable_with? rec
    return unless rec
    [price_fare, price_tax, validating_carrier_iata,  booking_classes, variants.first.flights.every.operating_carrier_iata, variants.first.flights.every.arrival_iata] == [rec.price_fare, rec.price_tax, rec.validating_carrier_iata,  rec.booking_classes, rec.variants.first.flights.every.operating_carrier_iata, rec.variants.first.flights.every.arrival_iata]
  end

  def hash
    signature.hash
  end

  def eql?(b)
    signature.eql?(b.signature)
  end
  
  def self.check_price_and_avaliability(flight_codes, pricer_form, validating_carrier_code)
    # FIXME вынести в Recommendation.from_flight_codes?
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
    amadeus = Amadeus::Service.new(:book => true)
    recommendation.price_fare, recommendation.price_tax =
      amadeus.fare_informative_pricing_without_pnr(
        :flights => flights, :people_count => pricer_form.real_people_count, :validating_carrier => validating_carrier_code
      ).prices

    # FIXME не очень надежный признак
    return if recommendation.price_fare.to_i == 0

    air_sfr = amadeus.air_sell_from_recommendation(:segments => segments, :people_count => (pricer_form.real_people_count[:adults] + pricer_form.real_people_count[:children]))
    amadeus.cmd('IG')
    return unless air_sfr.segments_confirmed?
    air_sfr.fill_itinerary!(segments)
    recommendation
  ensure
    amadeus.session.destroy
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
    departure_cities = []
    arrival_cities = []
    departure_airports = []
    arrival_airports = []
    departure_times = []
    arrival_times = []
    segments_amount = recs[0].variants[0].segments.length
    segments_amount.times {|i|
      departure_cities[i] = []
      arrival_cities[i] = []
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
          departure_cities[i] << summary['dpt_city_' + i.to_s]
          arrival_cities[i] << summary['arv_city_' + i.to_s]
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
    departure_cities.each_with_index {|cities, i|
      result['dpt_city_' + i.to_s] = cities.uniq.map{|city| {:v => city, :t => City[city].name} }.sort_by{|a| a[:t] }
    }
    arrival_cities.each_with_index {|cities, i|
      result['arv_city_' + i.to_s] = cities.uniq.map{|city| {:v => city, :t => City[city].name} }.sort_by{|a| a[:t] }
    }
    departure_airports.each_with_index {|airports, i|
      if result['dpt_city_' + i.to_s].size < 2
        result['dpt_airport_' + i.to_s] = airports.uniq.map{|airport| {:v => airport, :t => Airport[airport].name} }.sort_by{|a| a[:t] }
      end
    }
    arrival_airports.each_with_index {|airports, i|
      if result['arv_city_' + i.to_s].size < 2
        result['arv_airport_' + i.to_s] = airports.uniq.map{|airport| {:v => airport, :t => Airport[airport].name} }.sort_by{|a| a[:t] }
      end
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

  # фабрика для тестовых целей
  # Recommendation.example 'mowaer aermow/s7/c'
  # TODO сделать даты и пересадки и фальшивое время вылета
  def self.example itinerary, opts={}
    default_carrier = (opts[:carrier] || 'SU').upcase
    segments = []
    classes = []
    itinerary.split.each do |fragment|
      flight = Flight.new
      # defaults
      carrier, klass = default_carrier, 'Y'
      fragment.upcase.split('/').each do |code|
        case code.length
        when 6
          flight.departure_iata, flight.arrival_iata = code[0,3], code[3,3]
        when 2
          carrier = code
        when 1
          klass = code
        end
      end
      flight.operating_carrier_iata = carrier
      segments << Segment.new(:flights => [flight])
      classes << klass
    end
    Recommendation.new(
      :validating_carrier_iata => default_carrier,
      :variants => [Variant.new(:segments => segments)],
      :booking_classes => classes
    )
  end
end

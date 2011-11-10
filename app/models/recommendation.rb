# encoding: utf-8
class Recommendation

  include KeyValueInit

  attr_accessor :variants, :additional_info, :validating_carrier_iata, :cabins, :booking_classes, :source, :rules,
    :suggested_marketing_carrier_iatas, :availabilities, :upts, :last_tkt_date

  attr_accessor :blank_count

  delegate :marketing_carriers, :marketing_carrier_iatas,
    :operating_carriers, :operating_carrier_iatas,
    :city_iatas, :airport_iatas, :country_iatas, :route,
      :to => 'variants.first'

  delegate :subagent, :agent, :consolidator, :blanks, :discount, :ticketing, :to => :commission, :prefix => :commission, :allow_nil => true

  def availability
    availabilities.compact.min.to_i if availabilities
  end

  def validating_carrier
    validating_carrier_iata && Carrier[validating_carrier_iata]
  end

  # INTERLINES
  # ##########

  def other_marketing_carrier_iatas
    marketing_carrier_iatas - [validating_carrier_iata]
  end

  # FIXME? правильно работает только для recommendation с одним вариантом
  def rt
    (segments.length == 2) && (segments[0].departure_iata == segments[1].arrival_iata) && (segments[1].departure_iata == segments[0].arrival_iata)
  end

  def validating_carrier_participates?
    marketing_carrier_iatas.include?(validating_carrier_iata)
  end

  # предполагается, что у всех вариантов одинаковый набор marketing carrier-ов
  def validating_carrier_makes_half_of_itinerary?
    validating, other =
      variants.first.flights.every.marketing_carrier_iata.partition do |iata|
        iata == validating_carrier_iata
      end
    validating.size >= other.size
  end

  def validating_carrier_starts_itinerary?
    variants.first.flights.first.marketing_carrier_iata == validating_carrier_iata
  end

  def interline?
    @interline ||= other_marketing_carrier_iatas.any?
  end

  def international?
    country_iatas.uniq.size > 1
  end

  def domestic?
    country_iatas.uniq == [validating_carrier.country.iata]
  end

  def dept_date
    variants.first.segments.first.dept_date
  end

  def clear_variants
    #удаляем варианты на сегодня/завтра
    if source == 'amadeus'
      variants.delete_if{|v| v.with_bad_time || !TimeChecker.ok_to_show(v.departure_datetime_utc)}
    elsif source == 'sirena'
      variants.delete_if{|v| v.with_bad_time || !TimeChecker.ok_to_show_sirena(v.departure_datetime_utc)}
    end
  end

  # FIXME перенести в amadeus strategy?
  def valid_interline?
    # FIXME убрать проверку HR отсюда
    validating_carrier_iata == 'HR' or
    not interline? or
    other_marketing_carrier_iatas.uniq.all? do |iata|
      validating_carrier.interline_with?(iata)
    end
  end

  attr_accessor :price_fare, :price_tax, :price_our_markup

  # сумма, которая придет нам от платежного шлюза
  def price_total
    price_fare + price_tax + price_markup
  end

  # сумма для списывания с карточки
  def price_with_payment_commission
    price_total + price_payment
  end

  # комиссия платежного шлюза
  def price_payment
    Payture.commission(price_total)
  end

  # "налоги и сборы" для отображения клиенту
  def price_tax_and_markup
    price_tax + price_markup
  end

  # "налоги и сборы c комиссией" для отображения клиенту
  def price_tax_and_markup_and_payment
    price_tax + price_markup + price_payment
  end

  def price_agent
    return 0 unless commission
    commission_agent.call(price_fare, :multiplier =>  blank_count)
  end

  def price_subagent
    return 0 unless commission
    commission_subagent.call(price_fare, :multiplier =>  blank_count)
  end

  def price_consolidator
    return 0 unless commission
    commission_consolidator.call(price_fare, :multiplier => blank_count)
  end

  def price_blanks
    return 0 unless commission
    commission_blanks.call(price_fare, :multiplier => blank_count)
  end

  def price_discount
    return 0 unless commission
    commission_discount.call(price_fare, :multiplier => blank_count)
  end

  # надбавка к цене амадеуса
  def price_markup
    ajust_markup! if @price_our_markup.nil?
    price_our_markup + price_consolidator + price_blanks - (Conf.payment.use_discount ?  price_discount : 0 )
  end

  def ajust_markup!
    @price_our_markup = 0
  end

  def commission
    @commission ||=
      if source == 'sirena'
        Sirena::Commission.find_for(self)
      else
        Commission.find_for(self)
      end
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
    # consolidator-а пока не проверяем.
    # FIXME перепровить после подключения новых договоров
    # validating_carrier.consolidator && commission
    commission
  end

  def without_full_information?
    #проверяем, что все аэропорты и авиакомпании есть в базе
    flights.map {|f| f.arrival; f.departure; f.operating_carrier; f.marketing_carrier; f.equipment_type}
    false
  rescue IataStash::NotFound => e
    return true
  end

  def ground?
    flights.any? {|f| %W(train bus).include?(f.equipment_type.engine_type) }
  end

  def minimal_duration
    variants.map(&:total_duration).min
  end

  def self.merge left, right
    left | right
  end

  def variants_by_duration
    variants.sort_by(&:total_duration)
  end

  def has_equal_tariff? flight1, flight2
    flight1.marketing_carrier_iata == flight2.marketing_carrier_iata &&
      booking_class_for_flight(flight1) == booking_class_for_flight(flight2)
  end

  def summary
    result = {
      :price => price_with_payment_commission,
      :carrier => segments.first.marketing_carrier_name
    }
    alliance = validating_carrier.alliance
    if alliance
      result['alliance'] = alliance.id
    end
    variants.first.segments.each_with_index do |segment, i|
      result['dpt_location_' + i.to_s] = segment.departure.city.case_from.gsub(/ /, '&nbsp;')
      result['arv_location_' + i.to_s] = segment.arrival.city.case_to.gsub(/ /, '&nbsp;')
    end
    result
  end

  # comparison, uniquiness, etc.
  def signature
    [source, validating_carrier_iata, price_fare, price_tax, variants, booking_classes]
  end

  def hash
    signature.hash
  end

  def eql?(b)
    signature.eql?(b.signature)
  end
  alias == eql?

  def self.corrected recs
    #объединяем эквивалентные варианты
    recs.each_with_object([]) do |r, result|
      #некрасиво, но просто и работает
      if r.groupable_with? result[-1]
        result[-1].variants += r.variants
      elsif r.groupable_with? result[-2]
        result[-2].variants += r.variants
      elsif r.groupable_with? result[-3]
        result[-3].variants += r.variants
      else
        result << r
      end
    end
  end

  def groupable_with? rec
    return unless rec
    [price_fare, price_tax, validating_carrier_iata, booking_classes, marketing_carrier_iatas] == [rec.price_fare, rec.price_tax, rec.validating_carrier_iata,  rec.booking_classes, rec.marketing_carrier_iatas]
  end

  def booking_class_for_flight flight
    variants.each do |v|
      i = v.flights.index flight
      return booking_classes[i] if i
    end
    return
  end

  def cabin_for_flight flight
    variants.each do |v|
      i = v.flights.index flight
      return cabins[i] if i
    end
    return
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

  # попытка сделать код для script/amadeus
  def cryptic(variant=variants.first)
    ( [ "FV #{validating_carrier_iata}", "RMCABS #{cabins.join}"] +
      variant.flights.zip(booking_classes).map { |fl, cl| fl.cryptic(cl) }
    ).join('; ')
  end

  # сгодится для Recommendation.example
  def short(variant=variants.first)
    ( [ validating_carrier_iata ] +
      [ variant.flights, booking_classes, cabins].transpose.map { |fl, cl, cab|
        r = ["#{fl.departure_iata}#{fl.arrival_iata}"]
        if fl.marketing_carrier_iata != fl.operating_carrier_iata
          r << fl.carrier_pair
        elsif validating_carrier_iata != fl.marketing_carrier_iata
          r << fl.marketing_carrier_iata
        end
        r << 'BUSINESS' if cab == 'C'
        r << 'FIRST' if cab == 'F'
        r << cl if cl != 'Y'
        r.join('/')
      }
    ).join(' ')
  end

  # надеюсь, однажды это будет просто ключ из кэша
  def serialize(variant=nil)
    variant ||=
      if variants.one?
        variants.first
      else
        raise ArgumentError, "Recommendation#serialize without arguments works only if there's exactly one variant"
      end
    segment_codes = variant.segments.collect { |s|
      s.flights.collect(&:flight_code).join('-')
    }

    ( [ source, validating_carrier_iata, booking_classes.join(''), cabins.join(''), (availabilities || []).join('') ] +
      segment_codes ).join('.')
  end

  def self.deserialize(coded)
    # временная штука, пока не инвалидируем весь кэш старых рекомендаций
    coded = 'amadeus.' + coded unless coded =~ /^amadeus|^sirena/
    source, fv, classes, cabins, availabilities, *segment_codes = coded.split('.')
    variant = Variant.new(
      :segments => segment_codes.collect { |segment_code|
        Segment.new( :flights => segment_code.split('-').collect { |flight_code|
          Flight.from_flight_code(flight_code)
        })
      }
    )

    new(
      :source => source,
      :validating_carrier_iata => fv,
      :booking_classes => classes.split(''),
      :cabins => cabins.split(''),
      :variants => [variant],
      :availabilities => availabilities.split('')
    )
  end

  # FIXME порнография какая-то. чего так сложно?
  def self.summary recs, locations
    carriers = []
    planes = []
    cities = []
    departure_cities = []
    arrival_cities = []
    departure_airports = []
    arrival_airports = []
    departure_times = []
    arrival_times = []
    layovers = []
    segments_amount = recs[0].variants[0].segments.length
    segments_amount.times {|i|
      departure_cities[i] = []
      arrival_cities[i] = []
      departure_airports[i] = []
      arrival_airports[i] = []
      departure_times[i] = []
      arrival_times[i] = []
    }
    alliances = []
    recs.each {|r|
      r.variants.each{|v|
        summary = v.summary
        carriers += summary[:carriers]
        planes += summary[:planes]
        cities += summary[:cities]
        layovers << summary['layovers']
        v.segments.length.times {|i|
          departure_cities[i] << summary['dpt_city_' + i.to_s]
          arrival_cities[i] << summary['arv_city_' + i.to_s]
          departure_airports[i] << summary['dpt_airport_' + i.to_s]
          arrival_airports[i] << summary['arv_airport_' + i.to_s]
          departure_times[i] << summary['dpt_time_' + i.to_s]
          arrival_times[i] << summary['arv_time_' + i.to_s]
        }
      }
      alliances << r.summary['alliance']
    }
    layover_titles = ['без пересадок', 'только короткие пересадки', 'с одной пересадкой']
    result = {
      :carriers => carriers.uniq.map{|a| {:v => a, :t => Carrier[a].name}}.sort_by{|a| a[:t] },
      :planes => planes.uniq.map{|a| {:v => a, :t => Airplane[a].name}}.sort_by{|a| a[:t] },
      :cities => cities.uniq.map{|c| {:v => c, :t => City[c].name}}.sort_by{|a| a[:t] },
      :segments => segments_amount,
      :locations => locations,
      :layovers => layovers.flatten.uniq.sort.map{|l| {:v => l, :t => layover_titles[l] || ''}},
      :alliance => alliances.compact.uniq.map{|a| {:v => a, :t => AirlineAlliance.find(a).name}}.sort_by{|a| a[:t] }
    }
    departure_cities.each_with_index {|cities, i|
      result['dpt_city_' + i.to_s] = cities.uniq.map{|city| {:v => city, :t => City[city].case_from} }.sort_by{|a| a[:t] }
    }
    arrival_cities.each_with_index {|cities, i|
      result['arv_city_' + i.to_s] = cities.uniq.map{|city| {:v => city, :t => City[city].case_to} }.sort_by{|a| a[:t] }
    }
    departure_airports.each_with_index {|airports, i|
      if result['dpt_city_' + i.to_s].size < 2
        result['dpt_airport_' + i.to_s] = airports.uniq.map{|airport| {:v => airport, :t => Airport[airport].case_from} }.sort_by{|a| a[:t] }
      end
    }
    arrival_airports.each_with_index {|airports, i|
      if result['arv_city_' + i.to_s].size < 2
        result['arv_airport_' + i.to_s] = airports.uniq.map{|airport| {:v => airport, :t => Airport[airport].case_to} }.sort_by{|a| a[:t] }
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
    subclasses = []
    cabins = []
    fragments = itinerary.split
    if fragments.first.size == 2
      default_carrier = fragments.shift
    end
    fragments.each do |fragment|
      flight = Flight.new
      # defaults
      carrier, operating_carrier, subclass, cabin = default_carrier, nil, 'Y', 'M'
      fragment.upcase.split('/').each do |code|
        case code.length
        when 6
          flight.departure_iata, flight.arrival_iata = code[0,3], code[3,3]
        when 2
          carrier = code
        when 1
          subclass = code
        else
          case code
          when /^(..):(..)$/
            operating_carrier, carrier = $1, $2
          when 'ECONOMY'
            cabin = 'M'
          when 'BUSINESS'
            cabin = 'C'
          when 'FIRST'
            cabin = 'F'
          else
            raise ArgumentError, 'should consist of itinerary (SVOCDG), carrier(AB), cabin subclass (Y) or class (economy). example "mowaer/s7 aermow/y'
          end
        end
      end
      flight.marketing_carrier_iata = carrier
      flight.operating_carrier_iata = operating_carrier || carrier
      segments << Segment.new(:flights => [flight])
      subclasses << subclass
      cabins << cabin
    end
    Recommendation.new(
      :source => 'amadeus',
      :validating_carrier_iata => default_carrier,
      :variants => [Variant.new(:segments => segments)],
      :booking_classes => subclasses,
      :cabins => cabins
    )
  end
end


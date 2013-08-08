# encoding: utf-8
class Recommendation

  include KeyValueInit

  attr_accessor :variants, :additional_info, :validating_carrier_iata, :cabins, :booking_classes, :source, :rules,
    :suggested_marketing_carrier_iatas, :availabilities, :upts, :last_tkt_date, :declared_price, :baggage_array

  delegate :marketing_carriers, :marketing_carrier_iatas,
    :operating_carriers, :operating_carrier_iatas,
    :city_iatas, :airport_iatas, :country_iatas, :route,
      :to => 'variants.first'

  include Pricing::Recommendation
  include Commission::Includesonly

  # текущий маршрут. Использовать только при предварительном бронировании и далее.
  # Когда рекомендация обязана содержать только один вариант.
  def journey
    unless variants.size == 1
      raise TypeError, "can't ask for 'journey' when recommendation contains #{variants.size} variants"
    end
    variants.first
  end

  def self.from_yml str
    #триггеринг автолоад
    Recommendation; Variant; Flight; Segment; TechnicalStop; BaggageLimit
    YAML.load(str)
  end


  def availability
    availabilities.compact.min.to_i if availabilities
  end

  def validating_carrier
    validating_carrier_iata && Carrier[validating_carrier_iata]
  end

  # INTERLINES
  # ##########

  def other_marketing_carrier_iatas
    marketing_carrier_iatas - validating_carrier.all_iatas
  end

  # FIXME? правильно работает только для recommendation с одним вариантом
  def rt
    (segments.length == 2) && (segments[0].departure_iata == segments[1].arrival_iata) && (segments[1].departure_iata == segments[0].arrival_iata)
  end

  def validating_carrier_participates?
    (marketing_carrier_iatas & validating_carrier.all_iatas).present?
  end

  # FIXME вынести дублирование кода
  # предполагается, что у всех вариантов одинаковый набор marketing carrier-ов
  def validating_carrier_makes_more_than_half_of_itinerary?
    validating, other =
      variants.first.flights.every.marketing_carrier_iata.partition do |iata|
        iata.in?  validating_carrier.all_iatas
      end
    validating.size > other.size
  end

  # предполагается, что у всех вариантов одинаковый набор marketing carrier-ов
  def validating_carrier_makes_half_of_itinerary?
    validating, other =
      variants.first.flights.every.marketing_carrier_iata.partition do |iata|
        iata.in?  validating_carrier.all_iatas
      end
    validating.size >= other.size
  end

  def validating_carrier_starts_itinerary?
    variants.first.flights.first.marketing_carrier_iata.in? validating_carrier.all_iatas
  end

  def interline?
    @interline ||= other_marketing_carrier_iatas.any?
  end

  def codeshare?
    flights.any?(&:codeshare?)
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

  def dup_with_new_prices(prices)
    new_rec = dup
    new_rec.price_fare, new_rec.price_tax = prices
    new_rec.reset_commission!
    # FIXME отреагировать на изменение цены/продаваемости!
    new_rec.find_commission!
    new_rec
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
    # вернет true при отсутствии интерлайна тоже
    other_marketing_carrier_iatas.uniq.all? do |iata|
      validating_carrier.confirmed_interline_with?(iata)
    end
  end

  def segments
    variants.sum(&:segments)
  end

  def flights=(flights_array)
    self.variants = [Variant.new(:flights => flights_array)]
  end

  def flights
    segments.sum(&:flights)
  end

  def layovers?
    segments.any?(&:layovers?)
  end

  def sellable?
    #FIXME Временный костыль, приходят рейсы выполняемые аэросвитом
    return if flights.any? do |f|
      f.marketing_carrier_iata == 'PS' && booking_class_for_flight(f) == 'T'
    end
    commission.sellable?
  end

  def ignored_carriers
    ((marketing_carrier_iatas + operating_carrier_iatas) & Conf.amadeus.ignored_carriers).present?
  end

  def without_full_information?
    begin
      #проверяем, что все аэропорты и авиакомпании есть в базе
      flights.map do |f|
        raise 'Аэропорт прибытия не привязан к городу' unless f.arrival.known?
        raise 'Аэропорт прибытия не привязан к городу' unless f.departure.known?
        f.operating_carrier
        f.marketing_carrier
        f.equipment_type
      end
      false
    # Не хочется на первое время делать rescue Exception
    # логирования ради
    rescue RuntimeError => e
      true
    rescue CodeStash::NotFound => e
      true
    end
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

  def self.remove_unprofitable!(recommendations, income_at_least)
    recommendations.reject! {|r| r.income < income_at_least} if income_at_least
    recommendations
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
      v.flights.zip(booking_classes) do |other_flight, booking_class|
        return booking_class if flight.equal?(other_flight)
      end
    end
    return
  end

  def cabin_for_flight flight
    variants.each do |v|
      v.flights.zip(cabins) do |other_flight, cabin|
        return cabin if flight.equal?(other_flight)
      end
    end
    return
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
        if validating_carrier_iata != fl.marketing_carrier_iata ||
           validating_carrier_iata != fl.operating_carrier_iata
          r << fl.carrier_pair
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

    ( [ source, validating_carrier_iata, price_with_payment_commission.ceil, booking_classes.join(''), cabins.join(''), (availabilities || []).join('') ] +
      segment_codes ).join('.')
  end

  def self.deserialize(coded)
    # временная штука, пока не инвалидируем весь кэш старых рекомендаций
    coded = 'amadeus.' + coded unless coded =~ /^amadeus|^sirena/
    unless coded.split('.')[2] =~ /^\d+$/
      source, fv, classes, cabins, availabilities, *segment_codes = coded.split('.')
      declared_price = 0
    else
      source, fv, declared_price, classes, cabins, availabilities, *segment_codes = coded.split('.')
    end
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
      :declared_price => declared_price.to_i,
      :booking_classes => classes.split(''),
      :cabins => cabins.split(''),
      :variants => [variant],
      :availabilities => availabilities.split('')
    )
  end

  # FIXME недоделано - негде брать инфу о букинг классах, например
  def self.from_gds_code(validating_carrier_iata, code, source='amadeus')
    flights = code.split("\n").map{|fc| Flight.from_gds_code(fc, source)}.compact
    new(
      :source => source,
      :validating_carrier_iata => validating_carrier_iata,
      :variants => [Variant.new(:segments => flights.map {|f| Segment.new(:flights => [f])})]
      # booking classes ?
    )
  end

  def self.filters_data recs
    data = {}
    variants = recs.collect(&:variants).flatten 

    data[:time] = []
    data[:locations] = []
    layover_cities = []
    all_segments = variants.collect(&:segments)
    variants.first.segments.length.times {|i|
      segments = all_segments.every.at(i)
      departures = segments.every.departure
      arrivals = segments.every.arrival
      data[:locations][i] = {
        :dpt => {
          :cities => departures.every.city.uniq,
          :airports => departures.uniq
        },
        :arv => {
          :cities => arrivals.every.city.uniq,
          :airports => arrivals.uniq
        }
      }
      data[:time][i] = {
        :dpt => segments.every.departure_day_part.uniq.sort,
        :arv => segments.every.arrival_day_part.uniq.sort
      }
      layover_cities += segments.map{|s| s.flights[1..-1]}.flatten.map{|f| f.departure.city}
    }
    flights_count = variants.map{|v|
      v.segments.map{|s| s.flights.size}.max
    }.uniq
    data[:layover_cities] = layover_cities.uniq.sort_by(&:name)
    data[:few_layovers] = flights_count.min < 3 && flights_count.max > 2
    
    durations = all_segments.flatten.collect(&:layover_durations).flatten.compact
    unless durations.empty?
      data[:min_layover_duration] = durations.min / 60
      data[:max_layover_duration] = (durations.max.to_f / 60).ceil
    end

    flights = variants.collect(&:flights).flatten
    data[:alliances] = recs.every.validating_carrier.map{|vc| vc.alliance || nil}.compact.uniq.sort_by(&:name)
    data[:carriers] = all_segments.flatten.every.main_marketing_carrier.uniq
    data[:planes] = flights.every.equipment_type.uniq
    
    data
  end  

  # фабрика для тестовых целей
  # Recommendation.example 'mowaer aermow/s7/c'
  # TODO сделать даты и пересадки и фальшивое время вылета
  def self.example itinerary, opts={}
    default_carrier = (opts[:carrier] || 'SU').upcase
    segments = []
    subclasses = []
    cabins = []
    date_seq = (Date.today..(Date.today + 10)).to_enum
    fragments = itinerary.split
    if fragments.first.size == 2
      default_carrier = fragments.shift
    end
    fragments.each do |fragment|
      flight = Flight.new
      # defaults
      carrier, operating_carrier, flight_number, subclass, cabin = default_carrier, nil, nil, 'Y', 'M'
      fragment.upcase.split('/').each do |code|
        case code
        when /^.$/
          subclass = code
        when /^(..):(..)(\d*)$/, /^()(..)(\d*)$/
          operating_carrier, carrier, flight_number = $1, $2, $3
        when /^(...)(...)$/
          flight.departure_iata, flight.arrival_iata = $1, $2
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
      flight.marketing_carrier_iata = carrier
      flight.operating_carrier_iata = operating_carrier.presence || carrier
      flight.flight_number = flight_number.presence || '9999'
      flight.dept_date = date_seq.next
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


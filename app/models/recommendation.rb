# encoding: utf-8
class Recommendation

  # FIXME надо вынести во что-то амадеусовское?
  cattr_accessor :cryptic_logger
  cattr_accessor :short_logger
  self.cryptic_logger = ActiveSupport::BufferedLogger.new(Rails.root + 'log/rec_cryptic.log')
  self.short_logger = ActiveSupport::BufferedLogger.new(Rails.root + 'log/rec_short.log')
  cryptic_logger.auto_flushing = nil
  short_logger.auto_flushing = nil

  include KeyValueInit

  attr_accessor :variants, :additional_info, :validating_carrier_iata, :cabins, :booking_classes, :source, :rules,
    :suggested_marketing_carrier_iatas, :availabilities

  attr_accessor :sirena_blank_count

  delegate :marketing_carriers, :marketing_carrier_iatas,
    :city_iatas, :airport_iatas, :country_iatas,
      :to => 'variants.first'

  def availability
    availabilities.compact.min.to_i if availabilities
  end

  def validating_carrier
    validating_carrier_iata && Carrier[validating_carrier_iata]
  end

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

  def interline?
    other_marketing_carrier_iatas.any?
  end

  def international?
    country_iatas.uniq.size > 1
  end

  def domestic?
    country_iatas.uniq == [validating_carrier.country.iata]
  end

  def clear_variants
    #удаляем варианты на сегодня/завтра
    variants.delete_if{|v| v.segments[0].dept_date < Date.today + 2.days}
  end

  def valid_interline?
    not interline? or
    other_marketing_carrier_iatas.uniq.all? do |iata|
      validating_carrier.interline_with?(iata)
    end
  end

  attr_accessor :price_fare, :price_tax, :price_our_markup, :price_consolidator_markup

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

  # доля от комиссии консолидатора, которая достанется нам
  def price_share
    if commission
      commission.share(price_fare)
    else
      0
    end
  end

  # надбавка к цене амадеуса
  def price_markup
    ajust_markup! if @price_our_markup.nil? || @price_consolidator_markup.nil?
    price_our_markup + price_consolidator_markup
  end

  def ajust_markup!
    @price_our_markup = 0
    if price_share <= 5
      @price_consolidator_markup = (price_fare * 0.02)
    else
      @price_consolidator_markup = 0
    end
  end

  def commission
    @commission ||=
      if source == 'sirena'
        Commission.new(:agent => '0', :subagent => '0', :agent_comments => '', :subagent_comments => '')
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
    #проверяем, что все аэропорты есть в базе
    missed_iatas = (flights.every.arrival + flights.every.departure).uniq.find_all{|a| !a.id}.every.iata
    File.open(Rails.root + 'log/missed_iatas.log', 'a') {|f|
        f.write(missed_iatas.join(',') + ' ' + Time.now.strftime("%H:%M %d.%m.%Y") + "\n")
    } unless missed_iatas.blank?
    !missed_iatas.blank?
  end

  def ground?
    flights.any? {|f| %W(train bus).include?(f.equipment_type.engine_type) }
  end

  def minimal_duration
    variants.map(&:total_duration).min
  end

  def self.merge left, right
    merged = left | right

    # FIXME вынести логгер отсюдова
    merged.each do |r|
      r.variants.each do |v|
        cryptic_logger.info r.cryptic(v)
      end
      short_logger.info r.short
    end
    cryptic_logger.flush
    short_logger.flush

    merged
  end

  def self.load_from_cache(recommendation_number)
    # shouldn be neccessary, no?
    require 'segment'
    require 'variant'
    require 'flight'
    Cache.read('recommendation', recommendation_number)
  end

  def self.store_to_cache(recommendation_number, recommendation)
    Cache.write('recommendation', recommendation_number, recommendation)
  end


  def variants_by_duration
    variants.sort_by(&:total_duration)
  end

  def rules_with_flights
    rule_index = 0
    flights.each_with_object([]) do |flight, result|
      if result.blank? || !has_equal_tariff?(result.last[:flights].last, flight)
        result << {:rule => rules[rule_index], :flights => [flight]}
        rule_index += 1
      else
        result.last[:flights] << flight
      end
    end
  end

  def has_equal_tariff? flight1, flight2
    flight1.marketing_carrier_iata == flight2.marketing_carrier_iata &&
      booking_class_for_flight(flight1) == booking_class_for_flight(flight2)
  end

  def summary
    result = {
      :price => price_total,
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
  end

  def check_price_and_availability(pricer_form)
    if source == 'amadeus'
      Amadeus.booking do |amadeus|
        self.price_fare, self.price_tax =
          amadeus.fare_informative_pricing_without_pnr(
            :recommendation => self,
            :flights => flights,
            :people_count => pricer_form.real_people_count,
            :validating_carrier => validating_carrier_iata
          ).prices

        # FIXME не очень надежный признак
        return if price_fare.to_i == 0
        self.rules = amadeus.fare_check_rules.rules
        air_sfr = amadeus.air_sell_from_recommendation(
          :recommendation => self,
          :segments => segments,
          :seat_total => pricer_form.seat_total
        )
        amadeus.pnr_ignore
        return unless air_sfr.segments_confirmed?
        air_sfr.fill_itinerary!(segments)
        self
      end
    elsif source == 'sirena'
      recs = Sirena::Service.pricing(pricer_form, self).recommendations
      rec = recs && recs[0]
      self.rules = [] # для получения этой инфы для каждого тарифа нужно отправлять отдельный запрос fareremark
      if rec
        self.price_fare = rec.price_fare
        self.price_tax = rec.price_tax
        rec
      end
    end
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
  def serialize(variant)
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
    subclasses = []
    cabins = []
    itinerary.split.each do |fragment|
      flight = Flight.new
      # defaults
      carrier, subclass, cabin = default_carrier, 'Y', 'M'
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
          when 'ECONOMY'
            cabin = 'M'
          when 'BUSINESS'
            cabin = 'C'
          when 'FIRST'
            cabin = 'F'
          else
            raise ArgumentError, 'should consist of itinerary (MOWLON), carrier(AB), cabin subclass (Y) or class (economy). example "mowaer/s7 aermow/y'
          end
        end
      end
      flight.marketing_carrier_iata = carrier
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


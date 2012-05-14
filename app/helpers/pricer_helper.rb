# encoding: utf-8
module PricerHelper

  def nbsp(string)
    html_escape(string).gsub(/ +/, '&nbsp;').html_safe
  end

  def human_duration(duration)
    hours, minutes = duration.divmod(60)
    unless hours.zero?
      human_hours =
        "#{ hours }&nbsp;#{ Russian.pluralize(hours, 'час', 'часа', 'часов') }"
    end
    unless minutes.zero?
      human_minutes =
        "#{ minutes }&nbsp;#{ Russian.pluralize(minutes, 'минута', 'минуты', 'минут') }"
    end
    [human_hours, human_minutes].compact.join(' ').html_safe
  end

  def fmt_time time
    time[0,2] + ':' + time[2,2] if time
  end

  def fmt_date date
    [date[0,2],date[2,2],date[4,2]].join('.') if date
  end

  def fmt_date_short date
    date[0,2] + '.' + date[2,2] if date
  end

  def time_in_minutes time
    time ? (time[0,2].to_i * 60 + time[2,2].to_i) : 0
  end

  def short_human_duration duration
    hours, minutes = duration.divmod(60)
    unless hours.zero?
      human_hours =
        "#{ hours }&nbsp;ч"
    end
    unless minutes.zero?
      human_minutes =
        "#{ minutes }&nbsp;мин"
    end
    [human_hours, human_minutes].compact.join(' ').html_safe
  end  
  
  def airport_and_term location, term
    if term
      "#{ location.name } (#{ term })"
    else
      location.name
    end
  end
  
  def full_airport_and_term location, term
    result = ["#{ location.name }"]
    if term
      result << "терминал&nbsp;#{ term }"
    end
    result.join(', ').html_safe
  end    

  def recommendation_prices r
    prices = {
      :RUR => r.price_with_payment_commission.to_i
    }
    prices.to_json
  end
  
  def recommendation_comments r
    comments = []
    r.variants.every.flights.flatten.every.operating_carrier.uniq.each do |carrier|
      if carrier.comment
        comments << {
          :carrier => carrier.iata,
          :content => carrier.comment
        }
      end
    end
    comments
  end
  
  def recommendation_deficit r
    availability = r.availability  
    availability && availability > 0 && availability < 9
  end
  
  # группируем сегменты из нескольких вариантов
  def group_segments variants
    segments = []
    used = {}
    variants.each do |variant|
      variant.segments.each_with_index do |segment, scounter|
        sid = flight_codes(segment)
        unless used[sid]
          used[sid] = true
          segments[scounter] ||= []
          segments[scounter] << segment
        end
      end
    end
    segments.map do |segment|
      segment.sort_by {|s| [s.departure_time, s.total_duration] }
    end
  end

  # набор данных для работы фильтров
  def variant_features v, alliance
    features = []
    maxflights = v.segments.map{|s| s.flights.size }.max
    if maxflights == 1
      features << 'nonstop'
    elsif maxflights == 2
      features << 'onestop'
    end
    if alliance
      features << "alliance#{ alliance.id }"
    end
    features += v.flights.every.marketing_carrier.map{|carrier| 
      'carrier' + carrier.iata
    }
    features += v.flights.every.equipment_type.map{|plane|
      'plane' + plane.iata 
    }
    v.segments.each_with_index do |s, i|
      features << "dpt#{ i + 1 }t#{ s.departure_day_part }"
      features << "dpt#{ i + 1 }#{ s.departure.city.iata }"
      features << "dpt#{ i + 1 }#{ s.departure.iata }"
      features << "arv#{ i + 1 }t#{ s.arrival_day_part }"
      features << "arv#{ i + 1 }#{ s.arrival.city.iata }"
      features << "arv#{ i + 1 }#{ s.arrival.iata }"
      if s.flights.size > 1
        features += s.flights[1..-1].map{|f| 
          'lcity' + f.departure.city.iata
        }
      end 
    end
    features.uniq.join(' ')
  end
  
  # максимальная длительность пересадки
  def longest_layover v
      durations = v.segments.collect(&:layover_durations).flatten.compact  
      durations.max unless durations.empty?
  end

  # самый долгий перевозчик в сегменте
  def primary_carrier segment
    #segment.flights.group_by(&:operating_carrier_name).max_by{|carrier, flights| flights.sum(&:duration) }[1].first.operating_carrier
    segment.flights.group_by(&:marketing_carrier_name).max_by{|carrier, flights| flights.sum(&:duration) }[1].first.marketing_carrier
  end
  
  def segment_title segment
    "Перелет #{ nbsp(segment.departure.city.case_from) } #{ nbsp(segment.arrival.city.case_to) }".html_safe
  end

  def flight_codes segment
    segment.flights.collect(&:flight_code).join('-').html_safe
  end

  # данные для мини-диаграмм
  def segment_parts segment
    parts = []
    for flight, layover in segment.flights.zip(segment.layover_durations)
      parts << {
        :type => 'flight',
        :title => "Перелёт #{ flight.departure.city.case_from } #{ flight.arrival.city.case_to }, #{ human_duration(flight.duration) }",
        :duration => flight.duration
      }
      if layover
        parts << {
          :type => 'layover',
          :title => "Пересадка #{ flight.arrival.city.case_in }, #{ human_duration(layover) }",
          :duration => layover
        }
      end
    end
    parts
  end  
  
  def human_layovers_large segment
    result = []
    durations = segment.layover_durations
    segment.layovers.each_with_index{|layover, i|
      result << "#{ short_human_duration(durations[i]) } #{ layover.city.case_in }"
    }
    result.to_sentence
  end  

  def human_layovers_medium segment
    'через ' + segment.layovers.map{|layover| layover.city.case_to.gsub(/^\S+ /, '') }.to_sentence
  end

  def with_layovers segment
    counts = ['пересадкой', 'двумя пересадками', 'тремя пересадками']
    layovers = segment.flights[0..-2].map {|flight| flight.arrival.city.case_in }.to_sentence.gsub(/ (?!и )/, '&nbsp;')
    "c #{ counts[segment.layover_count - 1] } #{ layovers }".html_safe
  end

  def with_technical_stops flight
    prefix = flight.technical_stop_count == 1 ? 'промежуточной посадкой' : 'промежуточными посадками'
    stops = flight.technical_stops.map {|tstop| tstop.airport.city.case_in }.to_sentence.gsub(/ (?!и )/, '&nbsp;')
    "c #{ prefix} #{ stops }".html_safe
  end

  def human_cabin_nom cabin
    titles = {'Y' => 'Эконом-класс', 'C' => 'Бизнес-класс', 'F' => 'Первый класс'}
    titles[cabin]
  end

  def human_cabin_ins cabin
    titles = {'Y' => 'эконом-классом', 'C' => 'бизнес-классом', 'F' => 'первым классом'}
    titles[cabin]
  end    

  # отжирало 15% cpu time! теперь не отжирает
  def bar_options segment
    dpt = time_in_minutes(segment.departure_time)
    arv = time_in_minutes(segment.arrival_time)
    {
      :dpt => dpt, # местное время, минут
      :arv => dpt + segment.total_duration, # местное время в точке вылета на момент прилета, минут
      :shift => arv - (dpt + segment.total_duration) # для москвы-минска: -60
    }
  end

  def fmt_departure flight
    flight.departure_name + ' (' + flight.departure_iata +
      (flight.departure_term ? ' ' + flight.departure_term : '') +
    ')'
  end

  def fmt_arrival flight
    flight.arrival_name + ' (' + flight.arrival_iata +
      (flight.arrival_term ? ' ' + flight.arrival_term : '') +
    ')'
  end

  def fmt_duration duration
    "(%d:%02d)" % duration.divmod(60)
  end
  
  def rubles sum
    Russian.pluralize(sum, 'рубль', 'рубля', 'рублей')
  end

  def human_price price
    rounded = price.round.to_i
    "#{ rounded }&nbsp;#{ rubles(rounded) }".html_safe
  end  

  def human_date date
    I18n.l(Date.strptime(date, '%d%m%y'), :format => '%e %B')
  end

  def date_with_dow dmy
    date = Date.strptime(dmy, '%d%m%y')
    days = ['в понедельник', 'во вторник', 'в среду', 'в четверг', 'в пятницу', 'в субботу' , 'в воскресенье']
    I18n.l(date, :format => '%e %B') + ', ' + days[date.days_to_week_start]
  end

  def human_layovers_count count
    numbers = ['одной', 'двумя', 'тремя', 'четыремя', 'пятью']
    count == 1 ? 'пересадкой' : (numbers[count - 1] + ' пересадками —')
  end

  def layovers_in flights
    flights.map {|flight| flight.arrival.city.case_in }.to_sentence.gsub(/ (?!и )/, '&nbsp;').html_safe
  end

  def technical_stops_in tstops
    tstops.map {|tstop| tstop.airport.city.case_in }.to_sentence.gsub(/ (?!и )/, '&nbsp;').html_safe
  end

  def segments_departure variant
    variant.segments.map {|segment| segment.departure_time }.join(' ')
  end

  def human_cabin_nom cabin
    titles = {'Y' => 'Эконом-класс', 'C' => 'Бизнес-класс', 'F' => 'Первый класс'}
    titles[cabin]
  end

  def human_cabin_ins cabin
    titles = {'Y' => 'эконом-классом', 'C' => 'бизнес-классом', 'F' => 'первым классом'}
    titles[cabin]
  end

  def segment_flight_numbers segment
    segment.flights.map{|f| "#{f.marketing_carrier.iata}#{f.flight_number}" }.join('-')
  end

  def nearby_cities_list segments
    result = []
    index = {}
    segments.each_with_index do |segment, s|
      segment.nearby_cities.each_with_index do |cities, c|
        title = c == 0 ? segment.from_as_object.name_ru : segment.to_as_object.name_ru
        field = "#{c == 0 ? 'from' : 'to'}-#{s}"
        if index[title]
          index[title]['fields'] << field
        elsif !cities.empty?
          item = {}
          item['cities'] = cities.map{|c| c.name}
          item['fields'] = [field]
          item['title'] = title
          index[title] = item
          result << item
        end
      end
    end
    result
  end

  def variant_debug_info(recommendation, variant)
    # concat recommendation.source
    concat %( <a href="#" onclick="prompt('ctrl+c!', '#{h recommendation.cryptic(variant)}'); return false">КОД</a> ).html_safe if recommendation.source == 'amadeus'
    concat 'Наземный участок ' if recommendation.ground?
    concat 'Не можем продать ' unless recommendation.sellable?
    concat 'Нет интерлайна ' if recommendation.source == 'amadeus' && !recommendation.valid_interline?
    concat recommendation.validating_carrier_iata + ' '
    if recommendation.commission
      concat %( #{recommendation.commission.agent}/#{recommendation.commission.subagent})
      unless recommendation.commission.consolidator.zero?
        concat %( +#{recommendation.commission.consolidator})
        #concat %(, конс: #{recommendation.price_consolidator} р.)
      end
      unless recommendation.commission.our_markup.zero?
        concat %( #{recommendation.commission.our_markup})
      end
      unless recommendation.commission.discount.zero?
        concat %( -#{recommendation.commission.discount})
      end
      concat ' '
      concat recommendation.commission.ticketing_method
      # concat %( #{recommendation.price_subagent} р.)
      concat ' '
      concat link_to('комиссия', check_admin_commissions_url(:code => recommendation.serialize(variant)), :target => '_blank')
    elsif Commission.exists_for?(recommendation)
      concat link_to('не подходят правила', check_admin_commissions_url(:code => recommendation.serialize(variant)), :target => '_blank')
    else
      concat link_to('нет правил для авиакомпании)', admin_commissions_url, :target => '_blank')
    end
    concat " #{recommendation.blank_count} бл." if recommendation.blank_count && recommendation.blank_count > 1
    concat ' (' + recommendation.booking_classes.join(',') + ')'
    concat " Мест: #{recommendation.availability}"
  end

end


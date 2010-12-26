module PricerHelper
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
    [human_hours, human_minutes].compact.join(' ')
  end

  def fmt_time time
    time[0,2] + ':' + time[2,2] if time
  end

  def fmt_date date
    [date[0,2],date[2,2],date[4,2]].join('.') if date
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
  
  def human_price price
    "#{ price }&nbsp;#{ Russian.pluralize(price, 'рубль', 'рубля', 'рублей') }"
  end

  def human_date date
    I18n.l(Date.strptime(date, '%d%m%y'), :format => '%e %B')
  end
  
  def human_layovers_count count
    numbers = ['одной', 'двумя', 'тремя', 'четыремя', 'пятью']
    count == 1 ? 'пересадкой' : (numbers[count - 1] + ' пересадками —')
  end
  
  def layovers_in flights
    flights.map {|flight| flight.arrival.city.case_in }.to_sentence.gsub(/ (?!и )/, '&nbsp;')
  end
  
  def segments_departure variant
    variant.segments.map {|segment| segment.departure_time }.join(' ')
  end

  def variant_summary recommendation, excluded_variant=nil
    dept_segments = []
    recommendation.variants.each do |variant|
      variant.segments.each_with_index do |segment, i|
        if dept_segments[i].blank?
          dept_segments[i] = {'times' => [], 'city' => segment.departure.city}
        end
        dept_segments[i]['times'] << segment.dept_time
      end
    end
    result = []
    dept_segments.each_with_index do |segment, i|
      stimes = segment['times']
      stimes.delete(excluded_variant.segments[i].dept_time) if excluded_variant
      if stimes.length > 0
        time_links = stimes.uniq.sort.map {|t| "<a href=\"#\" data-segment=\"#{i}\"><u>#{t}</u></a>" }
        result << "<strong>#{segment['city'].case_from}</strong> — в #{time_links.to_sentence}"
      end
    end
    result.join(', ')
  end

  def human_cabin_nom cabin
    titles = {'Y' => 'Эконом-класс', 'C' => 'Бизнес-класс', 'F' => 'Первый класс'}
    titles[cabin]
  end

  def human_cabin_ins cabin
    titles = {'Y' => 'эконом-классом', 'C' => 'бизнес-классом', 'F' => 'первым классом'}
    titles[cabin]  
  end
  
  # FIXME отrubyить его посимпатишнее
  def primary_operating_carriers variant
    primary_carriers = []
    variant.segments.each_with_index do |segment, sindex|    
      carriers = {}
      primary_carriers[sindex] = {'duration' => 0}
      segment.flights.each do |f|
        cname = f.operating_carrier_name
        carriers[cname] = {'duration' => 0, 'name' => cname, 'icon_url' => f.operating_carrier.icon_url} unless carriers[cname]
        carriers[cname]['duration'] += f.duration
        if carriers[cname]['duration'] > primary_carriers[sindex]['duration']
          primary_carriers[sindex] = carriers[cname]
        end
      end
    end
    primary_carriers
  end

  def variant_debug_info(recommendation, variant)
    concat %(<a onclick="prompt('ctrl+c!', '#{recommendation.cryptic(variant)}');return false">КОД</a>)
    if recommendation.ground?
      concat %(<span style="color:red">наземный участок.</span>)
    end
    concat 'Не можем продать' unless recommendation.sellable?
    if recommendation.commission
      concat %( #{recommendation.commission.carrier}
        #{recommendation.commission.agent}
        #{recommendation.commission.subagent}
        #{recommendation.price_share} р.)
      unless recommendation.price_markup == 0
        concat %(#{recommendation.price_markup} р.)
      end
    else
      concat %(#{recommendation.validating_carrier_iata} <span style="color:red">нет комиссий</span>)
    end
  end

end


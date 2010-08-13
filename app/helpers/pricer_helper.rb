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
  
  def human_enumeration items
    items.length == 1 ? items.first : (items[0..-2].join(', ') + ' и ' + items.last)
  end
  
  def human_layovers_count count
    numbers = ['одной', 'двумя', 'тремя', 'четыремя', 'пятью']
    count == 1 ? 'пересадкой' : (numbers[count - 1] + ' пересадками —')
  end
  
  def layovers_in flights
    cities = []
    flights.each_with_index do |flight, i|
      city = flight.arrival.city.case_in
      cities << (i == 0 ? city.sub(/ /, '&nbsp;') : city.split(' ')[1])
    end
    human_enumeration(cities)
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
        result << "<strong>#{segment['city'].case_from}</strong> — в #{human_enumeration(time_links)}"
      end
    end
    result.join(', ')
  end

end


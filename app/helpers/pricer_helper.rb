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

  def variant_summary recommendation, excluded_variant=nil
    dept_times = Hash.new {[]}
    # FIXME вынести в Variant#dept_times ?
    recommendation.variants.every.segments.flatten.each do |segment|
      dept_times[segment.departure] |= [segment.dept_time]
    end

    excluded_variant.segments.each do |segment|
      dept_times[segment.departure] -= [segment.dept_time]
    end if excluded_variant

    dept_times.delete_if {|k,v| v.blank?}

    dept_times.map do |departure, times|
      "#{departure.city.case_from} &mdash; в #{times.sort.map{|t| "<a href=#><u>#{t}</u></a>" }.join(', ')}"
    end.join(', ')

  end

end


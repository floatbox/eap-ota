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

  def variant_summary recommendation
    result = []
    recommendation.variants.map { |v|
      v.segments.each_with_index{ |s, i|
        result[i] ||= {}
        result[i][:departure] = s.departure
        result[i][:times] ||= []
        result[i][:times] += [s.dept_time]
      }
    }
    result.map{|r|"#{r[:departure].city.case_from} в #{r[:times].uniq.join(', ')}" }.join(' ')
  end

end


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

  def human_price price
    rounded = price.round.to_i
    "#{ rounded }&nbsp;#{ Russian.pluralize(rounded, 'рубль', 'рубля', 'рублей') }".html_safe
  end

  def decorated_price price, price_tag='u', currency_tag='i'
    rounded = price.round.to_i
    (
      "<#{price_tag}>" +
      rounded.to_s.sub(/(\d)(\d{3})$/, '\1<span class="digit">\2</span>') +
      "</#{price_tag}>" +
      "<#{currency_tag}>" +
      '&nbsp;' + Russian.pluralize(rounded, 'рубль', 'рубля', 'рублей') +
      "</#{currency_tag}>"
    ).html_safe
  end

  def human_date date
    I18n.l(Date.strptime(date, '%d%m%y'), :format => '%e %B')
  end

  def date_with_dow date
    I18n.l(Date.strptime(date, '%d%m%y'), :format => '%e %B, %A')
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
    result.join(', ').html_safe
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

  # самый долгий перевозчик на каждом сегменте
  def primary_operating_carriers variant
    variant.segments.map do |segment|
      segment.flights.group_by(&:operating_carrier).max_by do |op_carrier, flights|
        flights.sum(&:duration)
      end.first
    end
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
      concat %( #{recommendation.price_share} р.)
      unless recommendation.price_markup == 0
        concat %(#{recommendation.price_our_markup} р.)
        unless recommendation.price_consolidator_markup == 0
          concat %(, конс: #{recommendation.price_consolidator_markup} р.)
        end
      end
    elsif Commission.exists_for?(recommendation)
      concat %(Не подходят правила)
    else
      concat %(Нет в договорe)
    end
    concat " #{recommendation.blank_count} бл." if recommendation.blank_count && recommendation.blank_count > 1
    concat '(' + recommendation.booking_classes.join(',') + ')'
  end

end


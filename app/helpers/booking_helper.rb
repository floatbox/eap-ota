# encoding: utf-8
module BookingHelper

  def uniq_cities segments
    (([segments.first.departure.city.case_to] + segments.map{|s| s.arrival.city.case_to}).uniq)[1..-1]
  end

  def utc_datetime(tz, date, time)
    tz.local_to_utc(DateTime.strptime(date + time, '%d%m%y%H%M'))
  end

  def order_event_params order
    segments = order.recommendation.segments
    cities = uniq_cities(segments)
    fs = segments.first
    ls = segments.last
    date1 = utc_datetime(fs.departure.city.tz, fs.departure_date, fs.departure_time).strftime('%Y%m%dT%H%M00Z')
    date2 = utc_datetime(ls.arrival.city.tz, ls.arrival_date, ls.arrival_time).strftime('%Y%m%dT%H%M00Z')
    result = []
    result << "text=#{segments.length == 1 ? 'Перелёт' : 'Поездка'} #{cities.to_sentence}"
    result << "dates=#{date1}/#{date2}"
    result << "location=Аэропорт #{fs.flights.first.departure_name}, #{fs.departure.city.name}"
    result.join('&')
  rescue
    ""
  end

  def order_summary order
    segments = order.recommendation.segments
    cities = uniq_cities(segments)
    parts = [order.people.size == 1 ? 'Лечу' : 'Летим']
    parts << cities.first
    parts << human_date(segments.first.departure_date)
    if cities.length > 1
      segments_summary = "#{parts.join(' ')}, потом #{cities[1..-1]}"
    elsif segments.length == 2
      days = Date.strptime(segments.last.arrival_date, '%d%m%y') - Date.strptime(segments.first.departure_date, '%d%m%y')
      parts << "на #{days.to_i} #{Russian.pluralize(days, 'день', 'дня', 'дней')}"
      segments_summary = parts.join(' ')
    else
      segments_summary = parts.join(' ')
    end
    price = order.recommendation.price_with_payment_commission.round.to_i
    price_parts = [price.to_s, Russian.pluralize(price, 'рубль', 'рубля', 'рублей')]
    if (order.people.size > 1)
      amounts = ['двоих', 'троих', 'четверых', 'пятерых']
      price_parts << "за #{order.people.size > 5 ? 'всех' : amounts[order.people.size - 2]}"
    end
    "#{segments_summary.gsub(/ +/, ' ')}. Билеты куплены на https://eviterra.com — #{price_parts.join(' ')}."
  rescue
    # FIXME dirty
    ""
  end

  def full_human_date date
    I18n.l(Date.strptime(date, '%d%m%y'), :format => '%e %B %Y')
  end
  
  def full_human_date_en date
    # Date.strptime(date, '%d%m%y').strftime('%e %B %Y')
    Date.strptime(date, '%d%m%y').to_s(:long)
  end
end

# encoding: utf-8
module BookingHelper

  NEAR_ABROAD_ISO = %W[ AZE ARM BLR GEO KAZ KGZ LVA LTU MDA TJK TKM UZB UKR EST ]

  def options_for_nationality_select
    # FIXME заменить на pluck в четвертых рельсах?
    nationalities = Country.select([:name_en, :name_ru, :alpha3]).all.map do |c|
      [dict(c), c.alpha3]
    end.sort

    nationality_groups = nationalities.group_by do |name, alpha3|
      case alpha3
      when 'RUS';            :default
      when *NEAR_ABROAD_ISO; :near_abroad
      else                   :rest
      end
    end

    separator = '&mdash;&mdash;&mdash;&mdash;'.html_safe

    [ ['',         nationality_groups[:default]],
      [ separator, nationality_groups[:near_abroad]],
      [ separator, nationality_groups[:rest]]
    ]
  end

  def uniq_cities segments
    (([segments.first.departure.city.case_to] + segments.map{|s| s.arrival.city.case_to}).uniq)[1..-1]
  end

  def utc_datetime(tz, date, time)
    tz.local_to_utc(DateTime.strptime(date + time, '%d%m%y%H%M'))
  end

  def order_event order
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

  def order_tweet order
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

  def human_week_day date
    I18n.l(Date.strptime(date, '%d%m%y'), :format => ' %A')
  end

  def full_human_date_en date
    # Date.strptime(date, '%d%m%y').strftime('%e %B %Y')
    Date.strptime(date, '%d%m%y').to_s(:long)
  end

  def human_week_day_en date
    Date.strptime(date, '%d%m%y').strftime(' %A')
  end

  def time_to_ticketing_delay date
    time = date.strftime('%H%M')
    case
      when time < '0600';  'до&nbsp;11&nbsp;утра по&nbsp;московскому времени'.html_safe
      when time < '0800';  'в&nbsp;течение четырех часов'.html_safe
      when time < '2030';  'в&nbsp;течение трех часов'.html_safe
      else                 'до&nbsp;11&nbsp;утра по&nbsp;московскому времени'.html_safe
    end
  end

end

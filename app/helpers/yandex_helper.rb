module YandexHelper
  def yandex_time(ourtime)
    if ourtime =~ /^(\d\d)(\d\d)$/
      return "#{$1}:#{$2}"
    end
  end

  def yandex_date(ourdate)
    if ourdate =~ /^(\d\d)(\d\d)(\d\d)$/
      return "20#{$3}-#{$2}-#{$1}"
    end
  end

  def yandex_cabin(cabin)
    {'F' => 'F', 'C' => 'C'}[cabin] || 'Y'
  end

  def yandex_url(search)
    "#{Conf.api.url_base}/##{@search.query_key}"
  end

  def yandex_newurl(search, recommendation, variant)
    "#{Conf.api.url_base}/api/booking/#{@search.query_key}#recommendation=#{recommendation.serialize(variant)}&type=api&partner=#{search.partner}"
  end
end

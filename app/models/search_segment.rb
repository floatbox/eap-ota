# encoding: utf-8

# non-persistent model
# используется для валидации поисковых сегментов
class SearchSegment
  include Virtus

  attribute :errors, Array, :default => []
  attribute :from, Search::Coercers::Location
  attribute :to, Search::Coercers::Location
  attribute :date, Search::Coercers::Date

  def valid?
    check_date
    errors.blank?
  end

  def check_arrival
    errors << 'В сегменте не может отсутствовать место прибытия' unless s.to
  end

  def check_date
    errors << 'В сегменте не может отсутствовать дата вылета' unless date
    if date.present? && !TimeChecker.ok_to_show(date + 1.day)
      errors << 'Первый вылет слишком рано'
    end
  end

  def from_country_or_region?
    [Country, Region].include? from.class
  end

  def search_around_from
    from.class == City && from.search_around
  end

  def search_around_to
    to.class == City && to.search_around
  end

  def to_country_or_region?
    [Country, Region].include? to.class
  end

  def multicity?
    from_country_or_region? || to_country_or_region?
  end

  def to_iata
    to.iata
  end

  def from_iata
    from.iata
  end

  def date_for_render
    date.strftime('%d%m%y')
  end

  def short_date
    date.strftime('%d.%m')
  end

  def nearby_cities
    [from, to].map do |location|
      if location.class == City
        location.nearby_cities
      elsif location.class == Airport
        location.city.nearby_cities
      else
        []
      end
    end
  end

end


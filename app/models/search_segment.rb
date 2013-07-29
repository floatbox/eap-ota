# encoding: utf-8

class SearchLocation < Virtus::Attribute::Object
  class LocationWriter < Virtus::Attribute::Writer::Coercible
    def coerce(value)
      case value
      when String then Completer.object_from_string(value)
      when ActiveRecord::Base then value
      else return
      end
    end
  end

  def self.writer_class(*)
    LocationWriter
  end
end

class SearchDate < Virtus::Attribute::Object
  class SearchDateWriter < Virtus::Attribute::Writer::Coercible
    def coerce(value)
      case value
      when String
        case value
        when /^\d{6}$/ then Date.strptime(value, '%d%m%y')
        when /%\d{2}\-\d{2}\-\d{2,4}$/ then Date.strptime(value, '%y-%m-%d')
        end
      when Date then value
      else return
      end
    ensure
    end
  end

  def self.writer_class(*)
    SearchDateWriter
  end

end

# non-persistent model
# используется для валидации поисковых сегментов
class SearchSegment
  include Virtus
  attribute :errors, Array, :default => []
  attribute :from, SearchLocation
  attribute :to, SearchLocation
  attribute :date, SearchDate

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


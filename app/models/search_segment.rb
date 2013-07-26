# encoding: utf-8

# non-persistent model
# используется для валидации поисковых сегментов
class SearchSegment
  include Virtus
  attribute :errors, Array, :default => []
  attribute :from, String
  attribute :to, String
  attribute :date, String

  def valid?
    check_date
    errors.blank?
  end

  def check_arrival
    errors << 'В сегменте не может отсутствовать место прибытия' unless s.to
  end

  def check_date
    errors << 'В сегменте не может отсутствовать дата вылета' unless date
    if date_as_date.present? && !TimeChecker.ok_to_show(date_as_date + 1.day)
      errors << 'Первый вылет слишком рано'
    end
  end

  def as_json(args = nil)
    args ||= {}
    args[:methods] = (args[:methods].to_a + [:to_as_object, :from_as_object]).uniq
    super(args)
  end

  def location_from_string name
    Completer.object_from_string(name)
  end

  def from_country_or_region?
    [Country, Region].include? from_as_object.class
  end

  def search_around_from
    from_as_object.class == City && from_as_object.search_around
  end

  def search_around_to
    to_as_object.class == City && to_as_object.search_around
  end

  def to_country_or_region?
    [Country, Region].include? to_as_object.class
  end

  def multicity?
    from_country_or_region? || to_country_or_region?
  end

  def date_as_date
    begin
      @date_as_date ||= Date.strptime(date, '%d%m%y')
    rescue
      nil
    end
  end

  def to_as_object
    @to_as_object ||= location_from_string(to)
  end

  def from_as_object
    @from_as_object ||= location_from_string(from)
  end

  def to_iata
    to_as_object_iata
  end

  def from_iata
    from_as_object_iata
  end

  def to_as_object_iata
    to_as_object.iata if to_as_object.respond_to? :iata
  end

  def from_as_object_iata
    from_as_object.iata if from_as_object.respond_to? :iata
  end

  def nearby_cities
    [from_as_object, to_as_object].map do |location|
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


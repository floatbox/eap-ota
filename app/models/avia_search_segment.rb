# encoding: utf-8

require 'search/coercers/location'
require 'search/coercers/date'

# non-persistent model
# используется для валидации поисковых сегментов
class AviaSearchSegment
  include Virtus
  include ActiveModel::Validations

  attribute :from, Search::Coercers::Location
  attribute :to, Search::Coercers::Location
  attribute :date, Search::Coercers::Date

  validates_presence_of :from, :to
  validate :date_validity

  def date_validity
    if date.present?
      errors.add(:date, 'invalid') unless TimeChecker.ok_to_show(date + 1.day)
    else
      errors.add(:date, "can't be blank")
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


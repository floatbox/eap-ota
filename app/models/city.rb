# encoding: utf-8
class City < ActiveRecord::Base
  include HasSynonyms
  extend IataStash

  TIMEZONE = TZInfo::Timezone.all_identifiers

  has_many :airports
  belongs_to :country
  belongs_to :region
  has_many :geo_taggings, :as => :location, :dependent => :destroy
  has_many :geo_tags, :through => :geo_taggings
  include GeoTaggable
  def latitude; lat end
  def longitude; lng end

  scope :important, where("importance > 0")
  scope :not_important, where("importance = 0")
  scope :with_country, includes(:country)
  scope :has_coords, where("lat is not null AND lng is not null")

  # UGLY
  # order теперь складывается, importance забивает все, except(:order) - не помог
  # выключил default_scope
  # c радиусом - неэффективно, но повторять "формулу"
  # три раза - некайф. а в 1.8 у lambda нет optional args
  scope :with_distance_to, lambda {|lat, lng, radius|
    formulae = "(ABS(lat - #{lat.to_f}) + ABS(lng - #{lng.to_f}))"
    select( "*, #{formulae} as distance") \
      .where( radius && ["#{formulae} < ?", radius] ) \
      .has_coords \
      .order("distance asc")
  }

  has_cases_for :name

  def self.nearest_to lat, lng
    return unless lat.present? && lng.present?
    with_distance_to( lat, lng, false).first
  end

  def nearby_cities
    City.with_distance_to( lat, lng, 4.5)\
      .where("id != ?", id).important.limit(10).to_a
  end

  def name
    name_ru.presence ||  name_en.presence || iata
  end

  def to_label
    "#{name} #{iata}"
  end

  # FIXME - сдохнет если nil.
  def tz
    TZInfo::Timezone.get(timezone)
  end

  def utc_offset date=Date.today
    time = date.to_time.utc
    (time - tz.local_to_utc(time)).to_i
  end

end


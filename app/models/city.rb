# encoding: utf-8
class City < ActiveRecord::Base
  include HasSynonyms
  include Cases
  extend CodeStash

  def self.fetch_by_code(code)
    find_by_iata(code)  # || find_by_iata_ru(code)
  end

  def codes
    [iata, iata_ru]
  end

  has_paper_trail

  def self.timezones
    TZInfo::Timezone.all_country_zone_identifiers.sort
  end

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

  scope :nearest_to, -> lat, lng, radius = 4.5 {
    formulae = "(ABS(lat - #{lat.to_f}) + ABS(lng - #{lng.to_f}))"

    # .has_coords не нужен, between отсечет
    select( "*, #{formulae} as distance")
      .where( lat: lat.to_f-radius..lat.to_f+radius)
      .where( lng: lng.to_f-radius..lng.to_f+radius)
      .order("distance asc")
  }

  def nearby_cities
    City.nearest_to( lat, lng, 4.5)\
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

  def inspect
    "#<#{self.class}:#{id||new}:(#{iata})>"
  end

end


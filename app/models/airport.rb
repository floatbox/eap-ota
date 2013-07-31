# encoding: utf-8
class Airport < ActiveRecord::Base
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

  belongs_to :city
  has_one :country, :through => :city
  has_many :geo_taggings, :as => :location, :dependent => :destroy
  has_many :geo_tags, :through => :geo_taggings
  include GeoTaggable

  def latitude; lat end
  def longitude; lng end

  delegate :tz, :to => :city
  scope :near, lambda {|other|
    radius = 10
    where(
        :lat => other.lat-radius..other.lat+radius,
        :lng => other.lng-radius..other.lng+radius
    )
  }

  scope :important, where("importance > 0")
  scope :not_important, where("importance = 0")
  scope :with_country, where("city_id is not null").includes(:city => :country)

  def name
    name_ru.presence || name_en.presence || iata

  end

  def equal_to_city
    city && city.name_ru == name_ru && city.iata == iata
  end

  def airports
    [self]
  end

  def inspect
    "#<#{self.class}:#{id||new}:(#{iata})>"
  end

end


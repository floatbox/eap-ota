# encoding: utf-8
class Airport < ActiveRecord::Base
  include HasSynonyms
  include Cases
  extend CodeStash

  class << self
    def fetch_by_code(code)
      find_by_iata(code)  # || find_by_iata_ru(code)
    end

    def make_by_code(code)
      # нет поддержки кириллицы для сирены
      if code =~ /^[A-Z]{3}$/
        Rails.logger.info "Airport with iata: #{code} autosaved to db"
        create(iata: code, auto_save: true)
      end
    end
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
  scope :lost, where(city_id: nil)
  scope :known, where('airports.city_id IS NOT NULL')
  scope :autosaved, where(auto_save: true)

  def known?
    !!city
  end

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


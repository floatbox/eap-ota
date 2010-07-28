class Airport < ActiveRecord::Base
  include ExtResource

  belongs_to :city
  has_one :country, :through => :city
  has_many :geo_taggings, :as => :location, :dependent => :destroy
  has_many :geo_tags, :through => :geo_taggings
  include GeoTaggable

  def latitude; lat end
  def longitude; lng end

  delegate :tz, :to => :city

  named_scope :near, lambda {|other|
    radius = 10
    { :conditions => {
        :lat => other.lat-radius..other.lat+radius,
        :lng => other.lng-radius..other.lng+radius
    } }
  }

  default_scope :order => "importance desc"

  def name
    name_ru.presence || name_en.presence || iata
  end

  def airports
    [self]
  end

end


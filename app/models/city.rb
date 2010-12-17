class City < ActiveRecord::Base
  include ExtResource
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

  default_scope :order => "importance desc"
  has_cases_for :name
  
  # UGLY
  def self.nearest_to lat, lng
    return unless lat.present? && lng.present?
    first :select => "*, (ABS(lat - #{lat.to_f}) + ABS(lng - #{lng.to_f})) as distance",
      :conditions => "lat is not null AND lng is not null",
      :order => "distance asc"
  end

  def nearby_cities
    City.all(:select => "*, (ABS(lat - #{lat.to_f}) + ABS(lng - #{lng.to_f})) as distance",
      :conditions => "lat is not null AND lng is not null AND
                      (ABS(lat - #{lat.to_f}) + ABS(lng - #{lng.to_f})) < 4.5 AND
                      id != #{id} AND
                      importance > 0",
      :order => "distance asc",
      :limit => 10)
  end

  def name
    name_ru.presence ||  name_en.presence || iata
  end
  
  def typus_name
    name + ' ' + iata
  end

  # FIXME - сдохнет если nil.
  def tz
    TZInfo::Timezone.get(timezone)
  end

end

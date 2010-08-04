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

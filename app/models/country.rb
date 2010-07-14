class Country < ActiveRecord::Base
  include ExtResource

  has_many :cities, :order => 'cities.name_ru'

  has_many :airports, :through => :cities
  has_many :geo_taggings, :as => :location, :dependent => :destroy
  has_many :geo_tags, :through => :geo_taggings
  has_many :airlines
  has_many :regions
  include GeoTaggable

  default_scope :order => "importance desc"
  has_cases_for :name
  
  def iata
    alpha2
  end
  
  def name
    name_ru
  end

  def icon_url
    if !alpha2.blank?
      url = "/system/countries/icons/#{alpha2.downcase}.png"
    end
    if !url || !File.exist?( Rails.root.to_s + '/public' + url)
      url = "/system/countries/icons/default.png"
    end
    url
  end

end

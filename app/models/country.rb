# encoding: utf-8
class Country < ActiveRecord::Base
  include HasSynonyms
  include Cases
  extend CodeStash

  def self.fetch_by_code code
    find_by_alpha2(code)
  end

  def codes
    [alpha2]
  end

  has_paper_trail

  # FIXME убрать order, лишнее замедление
  has_many :cities, :order => 'cities.name_ru'

  has_many :airports, :through => :cities
  has_many :geo_taggings, :as => :location, :dependent => :destroy
  has_many :geo_tags, :through => :geo_taggings
  has_many :carriers
  has_many :regions

  attr_writer :main_city_iatas_as_text #хак для typus
  include GeoTaggable

  def self.continents
   {'Азия' => 'asia', 'Америка' => 'america', 'Антарктика' => 'antarctica', 'Африка' => 'africa', 'Европа' => 'europe', 'Океания' => 'oceania'}
  end

  scope :important, where("importance > 0")
  scope :not_important, where("importance = 0")

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

  def main_city_iatas_as_text
    main_city_iatas.join(', ')
  end

  def main_city_iatas
    City.all(:conditions => ['country_id = ? AND disabled != ?', self.id, true], :order => 'importance DESC', :limit => 5).every.iata
  end

  def city_iatas
    @city_iatas ||= cities.pluck(:iata).compact
  end

end


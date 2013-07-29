# encoding: utf-8
class Country < ActiveRecord::Base
  include HasSynonyms
  include Cases
  extend IataStash

  has_paper_trail

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

  # для работы iata_stash
  def self.find_by_iata iata
    iata && find_by_alpha2(iata)
  end
  def self.find_by_iata_ru iata_ru; return; end

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

  # FIXME WTF? хотя бы iata коды использовать. не айдишники из базы!1
  def self.options_for_nationality_select
    [ ['', [['Россия', 170]]],
      [ '&mdash;&mdash;&mdash;&mdash;'.html_safe,
        [['Азербайджан', 3],
        ['Армения', 13],
        ['Беларусь', 20],
        ['Грузия', 58],
        ['Казахстан', 81],
        ['Киргизия', 88],
        ['Латвия', 102],
        ['Литва', 108],
        ['Молдова', 127],
        ['Таджикистан', 200],
        ['Туркмения', 211],
        ['Узбекистан', 214],
        ['Украина', 215],
        ['Эстония', 242]
      ]],
      ['&mdash;&mdash;&mdash;&mdash;'.html_safe,
        Country.all(:order => :name_ru).map{ |c|
          ([c.name_ru.to_s, c.id])
        }
      ]
    ]
  end
end


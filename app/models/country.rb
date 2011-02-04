# encoding: utf-8
class Country < ActiveRecord::Base
  include HasSynonyms

  has_many :cities, :order => 'cities.name_ru'

  has_many :airports, :through => :cities
  has_many :geo_taggings, :as => :location, :dependent => :destroy
  has_many :geo_tags, :through => :geo_taggings
  has_many :carriers
  has_many :regions
  include GeoTaggable

  scope :important, where("importance > 0")
  scope :not_important, where("importance = 0")

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

  def self.main_city_iatas(code)
    country = Country.find_by_alpha2(code)
    #country.cities.order('importance DESC').limit(5).every.iata
    City.find(:all, :conditions => ['country_id = ?', country.id], :limit => 5, :order => 'importance DESC').every.iata
  end

  # FIXME WTF? хотя бы iata коды использовать. не айдишники из базы!1
  def self.options_for_nationality_select
    [ ['', [['Россия', 170]]],
      [ '&mdash;&mdash;&mdash;&mdash;',
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
      ['&mdash;&mdash;&mdash;&mdash;',
        Country.all(:order => :name_ru).map{ |c|
          ([c.name_ru.to_s, c.id])
        }
      ]
    ]
  end
end

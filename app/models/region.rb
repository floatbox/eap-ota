# encoding: utf-8
class Region < ActiveRecord::Base
  include HasSynonyms
  include Cases

  belongs_to :country
  has_many :cities
  scope :important, where("importance > 0")
  scope :not_important, where("importance = 0")
  scope :with_country, includes(:country)
  attr_writer :main_city_iatas_as_text #хак для typus

  def self.region_types
    ['', 'штат', 'провинция']
  end

  def name
    name_ru || name_en
  end

  def main_city_iatas_as_text
    main_city_iatas.join(', ')
  end

  def main_city_iatas
    City.all(:conditions => ['region_id = ? AND disabled != ?', self.id, true], :order => 'importance DESC', :limit => 5).every.iata
  end
end


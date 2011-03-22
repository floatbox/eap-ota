# encoding: utf-8
class Region < ActiveRecord::Base
  belongs_to :country
  has_many :cities
  has_cases_for :name
  scope :important, where("importance > 0")
  scope :not_important, where("importance = 0")
  scope :with_country, includes(:country)

  def name
    name_ru || name_en
  end

  def main_city_iatas
    City.all(:conditions => ['region_id = ? AND disabled != ?', self.id, true], :order => 'importance DESC', :limit => 5).every.iata
  end
end


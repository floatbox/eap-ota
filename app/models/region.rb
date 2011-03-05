# encoding: utf-8
class Region < ActiveRecord::Base
  belongs_to :country
  has_many :cities
  has_cases_for :name

  def name
    name_ru || name_en
  end

  def main_city_iatas
    City.all(:conditions => ['region_id = ?', self.id], :order => 'importance DESC', :limit => 5).every.iata
  end
end


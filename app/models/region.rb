class Region < ActiveRecord::Base
  belongs_to :country
  has_many :cities
  
  def name
    name_ru || name_en
  end
end

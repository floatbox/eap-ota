class GeoTag < ActiveRecord::Base
  include ExtResource
  has_many :geo_taggings, :dependent => :destroy

  def locations
    geo_taggings.map &:location
  end

  def airports
    locations.map(&:airports).flatten.uniq
  end


  def latitude; lat end
  def longitude; lng end

  # awfully ineffective
  def self.update_coords
    all.each do |g|
      airports = g.airports
      if airports.size > 0
        g.lat = airports.every.lat.compact.sum / airports.size
        g.lng = airports.every.lng.compact.sum / airports.size
        g.save!
      end
    end
  end
end

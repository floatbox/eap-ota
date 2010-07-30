class AddMorpherFieldsToCityCountryAirport < ActiveRecord::Migration
  def self.up
    [:cities, :countries, :airports].each do |t|
      [:morpher_to, :morpher_from, :morpher_in].each do |m|
        add_column t, m, :string
      end
    end
  end

  def self.down
    [:cities, :counties, :airports].each do |t|
      [:morpher_to, :morpher_from, :morpher_in].each do |m|
        remove_column t, m
      end
    end
  end
end


class AddEqualToCityFieldToAirport < ActiveRecord::Migration
  def self.up
    add_column :airports, :equal_to_city, :boolean
  end

  def self.down
    remove_column :airports, :equal_to_city
  end
end


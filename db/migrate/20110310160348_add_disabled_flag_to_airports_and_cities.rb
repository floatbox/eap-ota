class AddDisabledFlagToAirportsAndCities < ActiveRecord::Migration
  def self.up
    add_column :airports, :disabled, :boolean
    add_column :cities, :disabled, :boolean
  end

  def self.down
    remove_column :airports, :disabled
    remove_column :cities, :disabled
  end
end


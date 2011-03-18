class AddIataRuToAirplanesAndCarriers < ActiveRecord::Migration
  def self.up
    add_column :airplanes, :iata_ru, :string
    add_column :carriers, :iata_ru, :string
  end

  def self.down
    remove_column :airplanes, :iata_ru
    remove_column :airplanes, :iata_ru
  end
end


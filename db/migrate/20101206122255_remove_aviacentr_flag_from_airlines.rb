class RemoveAviacentrFlagFromAirlines < ActiveRecord::Migration
  def self.up
    remove_column :airlines, :aviacentr
  end

  def self.down
    add_column :airlines, :aviacentr, :boolean
  end
end

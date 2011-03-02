class AddHotOffersCounterToDestinations < ActiveRecord::Migration
  def self.up
    add_column :destinations, :hot_offers_counter, :integer, :default => 0
  end

  def self.down
    remove_column :destinations, :hot_offers_counter
  end
end


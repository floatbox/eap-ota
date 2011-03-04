class AddDeltaAndAvgPriceFieldsToHotOffersAndDestinations < ActiveRecord::Migration
  def self.up
    add_index :hot_offers, :destination_id
    add_column :hot_offers, :time_delta, :integer
    add_column :hot_offers, :price_variation, :integer
    add_column :hot_offers, :price_variation_percent, :integer
    add_column :destinations, :average_price, :integer
    add_column :destinations, :average_time_delta, :integer
  end

  def self.down
    remove_index :hot_offers, :destination_id
    remove_column :hot_offers, :time_delta, :integer
    remove_column :hot_offers, :price_variation, :integer
    remove_column :hot_offers, :price_variation_percent, :integer
    remove_column :destinations, :average_price, :integer
    remove_column :destinations, :average_time_delta, :integer
  end
end


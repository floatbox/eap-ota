class AddDestinationIdToHotOffers < ActiveRecord::Migration
  def self.up
    add_column :hot_offers, :destination_id, :integer
  end

  def self.down
    remove_column :hot_offers, :destination_id
  end
end


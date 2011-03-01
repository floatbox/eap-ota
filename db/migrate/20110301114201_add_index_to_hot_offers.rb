class AddIndexToHotOffers < ActiveRecord::Migration
  def self.up
    add_index :hot_offers, :created_at
  end

  def self.down
    remove_index :hot_offers, :created_at
  end
end


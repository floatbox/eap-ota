class AddPriceDifferenceToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :price_difference, :decimal, :precision => 9, :scale => 2, :default => 0, :null => false
  end

  def self.down
    remove_column :orders, :price_difference
  end
end


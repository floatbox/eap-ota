class RemovePriceTotalFromOrders < ActiveRecord::Migration
  def self.up
    execute('update orders set price_fare = price_total where source = "other"')
    remove_column :orders, :price_total
  end

  def self.down
    add_column :orders, :price_total, :decimal, :precision => 9, :scale => 2, :default => 0, :null => false
  end
end


class ChangeAllPricesInOrdersToDecimal < ActiveRecord::Migration
  def self.up
    change_column :orders, :price_total, :decimal, :precision => 9, :scale => 2, :default => 0, :null => false
    change_column :orders, :price_share, :decimal, :precision => 9, :scale => 2, :default => 0, :null => false
    change_column :orders, :price_our_markup, :decimal, :precision => 9, :scale => 2, :default => 0, :null => false
    change_column :orders, :price_with_payment_commission, :decimal, :precision => 9, :scale => 2, :default => 0, :null => false
    change_column :orders, :price_fare, :decimal, :precision => 9, :scale => 2, :default => 0, :null => false
    change_column :orders, :price_tax, :decimal, :precision => 9, :scale => 2, :default => 0, :null => false
  end

  def self.down
    change_column :orders, :price_total, :integer
    change_column :orders, :price_share, :integer
    change_column :orders, :price_our_markup, :integer
    change_column :orders, :price_with_payment_commission, :integer
    change_column :orders, :price_fare, :integer
    change_column :orders, :price_tax, :integer
  end
end

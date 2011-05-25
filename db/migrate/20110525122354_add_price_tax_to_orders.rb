class AddPriceTaxToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :price_tax, :decimal, :precision => 9, :scale => 2, :default => 0, :null => false
    execute('update orders set price_tax = price_tax_and_markup - price_our_markup - price_consolidator_markup')
    remove_column :orders, :price_tax_and_markup
  end

  def self.down
    add_column :orders, :price_tax_and_markup, :decimal, :precision => 9, :scale => 2, :default => 0, :null => false
    execute('update orders set price_tax = price_tax + price_our_markup + price_consolidator_markup')
    remove_column :orders, :price_tax
  end
end


class ConvertPriceConsolidatorMarkupToDecimalInOrders < ActiveRecord::Migration
  def self.up
    change_column :orders, :price_consolidator_markup, :decimal, :precision => 9, :scale => 2, :default => 0, :null => false
  end

  def self.down
    change_column :orders, :price_consolidator_markup, :integer
  end
end

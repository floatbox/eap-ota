class SplitOrderDataMarkup < ActiveRecord::Migration
  def self.up
    rename_column :orders, :price_markup, :price_our_markup
    add_column :orders, :price_consolidator_markup, :integer
  end

  def self.down
    drop_column :orders, :price_consolidator_markup
    rename_column :orders, :price_our_markup, :price_markup
  end
end

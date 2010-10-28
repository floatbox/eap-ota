class RenameColumnsInOrders < ActiveRecord::Migration
  def self.up
    rename_column :orders, :markup, :price_share
    rename_column :orders, :extra, :price_markup
    remove_column :orders, :price_base
  end

  def self.down
    rename_column :orders, :price_share, :markup
    rename_column :orders, :price_markup, :extra
    add_column :orders, :price_base, :integer
  end
end

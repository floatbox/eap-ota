class AddBlankCountToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :blank_count, :integer
  end

  def self.down
    remove_column :orders, :blank_count
  end
end

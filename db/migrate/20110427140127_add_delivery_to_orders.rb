class AddDeliveryToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :delivery, :text
  end

  def self.down
    remove_column :orders, :delivery
  end
end


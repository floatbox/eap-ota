class AddOrderIdIndexToNotifications < ActiveRecord::Migration
  def change
    add_index :notifications, :order_id
  end
end

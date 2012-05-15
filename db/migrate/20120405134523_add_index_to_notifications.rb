class AddIndexToNotifications < ActiveRecord::Migration
  def change
    add_index :notifications, [:method, :status]
  end
end

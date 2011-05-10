class AddOfflineBookingFlagToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :offline_booking, :boolean, :default => false
  end

  def self.down
    remove_column :orders, :offline_booking
  end
end


class AddOldDowntownBookingToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :old_downtown_booking, :boolean, :default => false
  end
end

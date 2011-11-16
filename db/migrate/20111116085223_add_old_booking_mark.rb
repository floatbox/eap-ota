class AddOldBookingMark < ActiveRecord::Migration
  def up
    add_column :orders, :old_booking, :boolean, :null => false, :default => false
    execute "update orders set old_booking=1"
  end

  def down
    remove_column :orders, :old_booking
  end
end

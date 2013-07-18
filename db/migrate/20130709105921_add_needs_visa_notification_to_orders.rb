class AddNeedsVisaNotificationToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :needs_visa_notification, :boolean, :default => false
  end
end

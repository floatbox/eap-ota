class AddEmailStatusToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :email_status, :string, :default => '', :null => false
  end

  def self.down
    remove_column :orders, :email_status
  end
end

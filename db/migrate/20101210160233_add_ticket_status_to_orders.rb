class AddTicketStatusToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :ticket_status, :string
  end

  def self.down
    remove_column :orders, :ticket_status
  end
end

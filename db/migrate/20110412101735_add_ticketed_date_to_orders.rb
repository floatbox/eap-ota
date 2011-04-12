class AddTicketedDateToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :ticketed_date, :date
  end

  def self.down
    remove_column :orders, :ticketed_date
  end
end


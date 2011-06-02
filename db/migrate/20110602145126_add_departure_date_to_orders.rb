class AddDepartureDateToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :departure_date, :date
  end

  def self.down
    remove_column :carriers, :departure_date
  end
end

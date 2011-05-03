class AddCabinsToOrdersAndTickets < ActiveRecord::Migration
  def self.up
    add_column :orders, :cabins, :string
    add_column :tickets, :cabins, :string
  end

  def self.down
    remove_column :orders, :cabins
    remove_column :tickets, :cabins
  end
end


class AddTicketsFieldToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :tickets, :string
  end

  def self.down
    remove_column :orders, :tickets
  end
end


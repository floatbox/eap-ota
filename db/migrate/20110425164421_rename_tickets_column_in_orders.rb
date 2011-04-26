class RenameTicketsColumnInOrders < ActiveRecord::Migration
  def self.up
    rename_column :orders, :tickets, :ticket_numbers_as_text
  end

  def self.down
    rename_column :orders, :ticket_numbers_as_text, :tickets
  end
end


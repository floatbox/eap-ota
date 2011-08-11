class RemoveTicketNumberAsTextFromOrders < ActiveRecord::Migration
  def self.up
    remove_column :orders, :ticket_numbers_as_text
  end

  def self.down
    add_column :orders, :ticket_numbers_as_text, :string
  end
end

class AddPassengerFieldsToTickets < ActiveRecord::Migration
  def self.up
    add_column :tickets, :first_name, :string
    add_column :tickets, :last_name, :string
    add_column :tickets, :passport, :string
  end

  def self.down
    remove_column :tickets, :first_name
    remove_column :tickets, :last_name
    remove_column :tickets, :passport
  end
end

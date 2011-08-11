class AddCodeToTickets < ActiveRecord::Migration
  def self.up
    add_column :tickets, :code, :string
  end

  def self.down
    remove_column :tickets, :code
  end
end

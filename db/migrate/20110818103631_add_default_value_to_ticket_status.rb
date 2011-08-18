class AddDefaultValueToTicketStatus < ActiveRecord::Migration
  def up
    change_column :orders, :ticket_status, :string, :default => 'booked'
  end
  
  def down
    change_column :orders, :ticket_status, :string
  end
end

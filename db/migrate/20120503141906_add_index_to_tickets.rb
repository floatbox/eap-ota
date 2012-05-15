class AddIndexToTickets < ActiveRecord::Migration
  def change
    add_index :tickets, :pnr_number
    add_index :tickets, :order_id
    add_index :tickets, :parent_id
    add_index :tickets, :office_id
    add_index :tickets, :status
    add_index :tickets, :kind
  end
end

class AddIndexToOrders < ActiveRecord::Migration
  def change
    add_index :orders, :pnr_number
    add_index :orders, [:payment_status, :ticket_status]
    add_index :orders, :payment_status
    add_index :orders, :ticket_status
    add_index :orders, :payment_type
    add_index :orders, :partner
  end
end

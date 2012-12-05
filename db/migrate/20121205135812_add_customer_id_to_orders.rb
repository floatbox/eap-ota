class AddCustomerIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :customer_id, :integer
    add_index :orders, :customer_id
  end
end

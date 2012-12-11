class AddOrderIdIndexToPayments < ActiveRecord::Migration
  def change
    add_index "payments", ["order_id"]
  end
end

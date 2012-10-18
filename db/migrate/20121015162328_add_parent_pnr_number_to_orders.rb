class AddParentPnrNumberToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :parent_pnr_number, :string
  end
end

class AddShowVatToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :show_vat, :boolean, :default => false
  end
end

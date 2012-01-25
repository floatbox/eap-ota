class AddMarkerToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :marker, :string
  end
end

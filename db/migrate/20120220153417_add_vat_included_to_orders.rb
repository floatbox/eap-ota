class AddVatIncludedToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :vat_included, :boolean, :default => false, :null => false
  end
end

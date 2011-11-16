class AddConsolidatorMarkupToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :commission_consolidator_markup, :string
  end
end

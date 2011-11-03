class AddCommissionDiscountToOrders < ActiveRecord::Migration
  def change
    change_table :orders do |t|
      t.string :commission_discount
      t.decimal :price_discount, :precision => 9, :scale => 2, :default => 0.0,      :null => false
    end
  end
end

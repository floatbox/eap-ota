class AddDiscountToTickets < ActiveRecord::Migration
  change_table :tickets do |t|
    t.string :commission_discount
    t.decimal :price_discount, :precision => 9, :scale => 2, :default => 0.0,      :null => false
  end
end

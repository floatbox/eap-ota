class AddOurMarkupToTicketsAndOrders < ActiveRecord::Migration
  def change
    add_column :orders, :commission_our_markup, :string
    add_column :tickets, :commission_our_markup, :string
    add_column :tickets, :price_our_markup, :decimal, :precision => 9, :scale => 2, :default => 0.0, :null => false
  end
end

class AddPriceDifferenceToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :price_difference, :decimal, :precision => 9, :scale => 2, :default => 0, :null => false
  end
end

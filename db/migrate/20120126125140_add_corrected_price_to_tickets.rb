class AddCorrectedPriceToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :corrected_price, :decimal, :precision => 9, :scale => 2, :default => nil, :null => true
  end
end

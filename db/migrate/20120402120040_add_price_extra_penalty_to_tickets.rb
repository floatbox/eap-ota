class AddPriceExtraPenaltyToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :price_extra_penalty, :decimal, :precision => 9, :scale => 2, :default => 0, :null => false
  end
end

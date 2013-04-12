class AddStoredPricePaymentCommissionToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :stored_price_payment_commission, :decimal, :precision => 9, :scale => 2, :default => 0, :null => false
  end
end

class AddPriceAcquiringCompensationToOrdersAndTickets < ActiveRecord::Migration
  def change
    add_column :orders, :price_acquiring_compensation, :decimal, :precision => 9, :scale => 2, :default => 0, :null => false
    rename_column :tickets, :stored_price_payment_commission, :price_acquiring_compensation
  end
end

class AddCashPaymentMarkupToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :cash_payment_markup,  :decimal, :precision => 9, :scale => 2, :default => 0, :null => false
  end

  def self.down
    remove_column :orders, :cash_payment_markup
  end
end


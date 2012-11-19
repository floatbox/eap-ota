class AddStoredIncomeAndStoredBalanceToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :stored_income, :decimal, :precision => 9, :scale => 2, :default => 0, :null => false
    add_column :orders, :stored_balance, :decimal, :precision => 9, :scale => 2, :default => 0, :null => false
  end
end

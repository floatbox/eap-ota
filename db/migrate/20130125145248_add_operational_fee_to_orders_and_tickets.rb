class AddOperationalFeeToOrdersAndTickets < ActiveRecord::Migration
  def up
    add_column :orders, :price_operational_fee, :decimal, :precision => 9, :scale => 2, :default => 0, :null => false
    add_column :tickets, :price_operational_fee, :decimal, :precision => 9, :scale => 2, :default => 0, :null => false
  end

  def down
    remove_column :tickets, :price_operational_fee
    add_column :orders, :price_operational_fee
  end
end

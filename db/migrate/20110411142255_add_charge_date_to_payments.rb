class AddChargeDateToPayments < ActiveRecord::Migration
  def self.up
    add_column :payments, :charge_date, :date
  end

  def self.down
    remove_column :payments, :charge_date
  end
end


class AddPanIndexToPayments < ActiveRecord::Migration
  def change
    add_index :payments, :pan
  end
end

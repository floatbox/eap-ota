class AddHasRefundsToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :has_refunds, :boolean, :default => false, :null => false
  end
end

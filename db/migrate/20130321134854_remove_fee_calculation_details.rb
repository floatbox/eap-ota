class RemoveFeeCalculationDetails < ActiveRecord::Migration
  def up
    remove_column :tickets, :fee_calculation_details
    remove_column :orders, :fee_calculation_details
  end

  def down
    add_column :tickets, :fee_calculation_details, :text, :default => '', :null => false
    add_column :orders, :fee_calculation_details, :text, :default => '', :null => false
  end
end

class AddFeeCalculationDetailsToOrdersAndTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :fee_calculation_details, :text, :default => '', :null => false
    add_column :orders, :fee_calculation_details, :text, :default => '', :null => false
  end
end

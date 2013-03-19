class AddFeeSchemeToOrdersAndTickets < ActiveRecord::Migration
  def change
    add_column :orders, :fee_scheme, :string, :default => ''
    add_column :tickets, :fee_scheme, :string, :default => ''
  end
end

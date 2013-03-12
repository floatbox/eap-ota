class AddFeeSchemeToOrdersAndTickets < ActiveRecord::Migration
  def change
    add_column :orders, :fee_scheme, :string, :default => 'v2'
    add_column :tickets, :fee_scheme, :string, :default => 'v2'
  end
end

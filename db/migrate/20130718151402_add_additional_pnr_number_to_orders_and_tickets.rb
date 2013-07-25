class AddAdditionalPNRNumberToOrdersAndTickets < ActiveRecord::Migration
  def change
    add_column :orders, :additional_pnr_number, :string
    add_column :tickets, :additional_pnr_number, :string
  end
end

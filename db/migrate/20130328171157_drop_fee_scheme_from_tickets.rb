class DropFeeSchemeFromTickets < ActiveRecord::Migration
  def up
    remove_column :tickets, :fee_scheme
  end

  def down
    add_column :tickets, :fee_scheme, :string, :default => ''
  end
end

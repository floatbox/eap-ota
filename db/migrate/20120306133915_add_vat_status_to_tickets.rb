class AddVatStatusToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :vat_status, :string, :null => false, :default => 'unknown'
  end
end

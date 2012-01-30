class AddVatIncludedToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :vat_included, :boolean
  end
end

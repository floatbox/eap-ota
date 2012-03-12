class RemoveOldVatColumns < ActiveRecord::Migration
  def up
    remove_column :orders, :show_vat
    remove_column :orders, :vat_included
    remove_column :tickets, :vat_included
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

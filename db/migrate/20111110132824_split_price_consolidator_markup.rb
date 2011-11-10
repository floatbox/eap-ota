class SplitPriceConsolidatorMarkup < ActiveRecord::Migration
  def up
    rename_column :orders, :commission_consolidator_markup, :commission_consolidator
    change_table :orders do |t|
      t.string :commission_blanks
      t.decimal :price_consolidator, :precision => 9, :scale => 2, :default => 0.0, :null => false
      t.decimal :price_blanks, :precision => 9, :scale => 2, :default => 0.0, :null => false
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

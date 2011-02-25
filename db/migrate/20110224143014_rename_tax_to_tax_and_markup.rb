class RenameTaxToTaxAndMarkup < ActiveRecord::Migration
  def self.up
    rename_column :orders, :price_tax, :price_tax_and_markup
  end

  def self.down
    rename_column :orders, :price_tax_and_markup, :price_tax
  end
end

class RenameOriginalPriceColumns < ActiveRecord::Migration
  def up
    rename_column :tickets, :original_fare_cents, :original_price_fare_cents
    rename_column :tickets, :original_tax_cents, :original_price_tax_cents
    rename_column :tickets, :original_fare_currency, :original_price_fare_currency
    rename_column :tickets, :original_tax_currency, :original_price_tax_currency
  end

  def down
    rename_column :tickets, :original_price_fare_cents, :original_fare_cents
    rename_column :tickets, :original_price_tax_cents, :original_tax_cents
    rename_column :tickets, :original_price_fare_currency, :original_fare_currency
    rename_column :tickets, :original_price_tax_currency, :original_tax_currency
  end
end

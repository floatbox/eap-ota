class AddCurrencyDetailsToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :original_fare_cents, :integer

    add_column :tickets, :original_fare_currency, :string, :limit => 3

    add_column :tickets, :original_tax_cents, :integer

    add_column :tickets, :original_tax_currency, :string, :limit => 3

  end
end

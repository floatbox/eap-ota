class AddOriginalPricePenaltyColumnsToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :original_price_penalty_cents, :integer
    add_column :tickets, :original_price_penalty_currency, :string, :limit => 3
  end
end

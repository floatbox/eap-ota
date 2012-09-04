class CreateCurrencyRates < ActiveRecord::Migration
  def change
    create_table :currency_rates do |t|
      t.string :from
      t.string :to
      t.string :bank
      t.float :rate
      t.date :date

      t.timestamps
    end
  end
end

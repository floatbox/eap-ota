class CreateFareRules < ActiveRecord::Migration
  def change
    create_table :fare_rules do |t|
      t.string :carrier
      t.string :fare_base
      t.string :to_iata
      t.string :from_iata
      t.string :passenger_type
      t.text :rule_text
      t.references :order, index: true
      t.timestamps
    end
    add_index :fare_rules, :order_id
  end
end

class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.integer :order_id
      t.decimal :price, :precision => 9, :scale => 2, :default => 0, :null => false
      p.string :last_digits_in_card
      p.string :name_in_card

      t.timestamps
    end
  end

  def self.down
    drop_table :payments
  end
end


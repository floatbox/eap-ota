class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.decimal :price, :precision => 9, :scale => 2, :default => 0, :null => false
      t.string :last_digits_in_card
      t.string :name_in_card
      t.string :payment_system_name
      t.string :payment_status
      t.integer :transaction_id
      t.integer :refund_transaction_id

      t.timestamps
    end
  end

  def self.down
    drop_table :payments
  end
end


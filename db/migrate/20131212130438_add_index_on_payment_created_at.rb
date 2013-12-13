class AddIndexOnPaymentCreatedAt < ActiveRecord::Migration
  def up
    add_index :payments, :created_at
  end

  def down
    remove_index :payment, :created_at
  end
end

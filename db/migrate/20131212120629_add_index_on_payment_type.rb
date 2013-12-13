class AddIndexOnPaymentType < ActiveRecord::Migration
  def up
    add_index :payments, :type
  end

  def down
    remove_index :payments, :type
  end
end

class AddIndexOnOrdersEmailStatus < ActiveRecord::Migration
  def up
    add_index :orders, :email_status
  end

  def down
    remove_index :orders, :email_status
  end
end

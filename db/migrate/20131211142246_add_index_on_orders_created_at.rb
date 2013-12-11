class AddIndexOnOrdersCreatedAt < ActiveRecord::Migration
  def up
    add_index :orders, :created_at
  end

  def down
    remove_index :orders, :created_at
  end
end

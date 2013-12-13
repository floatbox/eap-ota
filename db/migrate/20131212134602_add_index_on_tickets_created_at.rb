class AddIndexOnTicketsCreatedAt < ActiveRecord::Migration
  def up
    add_index :tickets, :created_at
  end

  def down
    remove_index :tickets, :created_at
  end
end

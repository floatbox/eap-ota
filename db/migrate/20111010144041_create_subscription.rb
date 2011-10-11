class CreateSubscription < ActiveRecord::Migration
  def up
    create_table :subscriptions do |t|
      t.integer  :destination_id, :null => false
      t.string   :email, :null => false
      t.string   :status, :null => false, :default => ''
      t.timestamps
    end
    add_index :subscriptions, [:destination_id]
  end

  def down
    remove_index :subscriptions, [:destination_id]
    drop_table :subscriptions
  end
end

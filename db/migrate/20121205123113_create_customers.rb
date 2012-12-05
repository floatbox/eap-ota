class CreateCustomers < ActiveRecord::Migration

  def change
    create_table :customers do |t|
      t.string :email, :null => false
      t.string :password
      t.string :status
      t.boolean :enabled, :null => false, :default => 0

      t.timestamps
    end
    add_index :customers, :email, :unique => true
  end
end

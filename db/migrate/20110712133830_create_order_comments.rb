class CreateOrderComments < ActiveRecord::Migration
  def self.up
    create_table :order_comments do |t|
      t.integer :order_id
      t.integer :typus_user_id
      t.text :text, :null => false
    
      t.timestamps
    end
  end

  def self.down
    drop_table :order_comments
  end
end

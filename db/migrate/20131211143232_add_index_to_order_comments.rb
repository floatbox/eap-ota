class AddIndexToOrderComments < ActiveRecord::Migration
  def change
    add_index :order_comments, :order_id
    add_index :order_comments, :created_at
  end
end

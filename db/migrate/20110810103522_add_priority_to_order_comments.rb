class AddPriorityToOrderComments < ActiveRecord::Migration
  def self.up
    add_column :order_comments, :priority, :string
  end

  def self.down
    remove_column :order_comments, :priority
  end
end

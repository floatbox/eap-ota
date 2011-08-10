class ChangePriorityToIntegerInOrderComments < ActiveRecord::Migration
  def self.up
    change_column :order_comments, :priority, :integer
  end

  def self.down
    change_column :order_comments, :priority, :string
  end
end

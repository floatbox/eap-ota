class AddStatusAndAssignedToIdToOrderComments < ActiveRecord::Migration
  def self.up
    add_column :order_comments, :assigned_to_id, :integer
    add_column :order_comments, :status, :string
  end

  def self.down
    remove_column :order_comments, :assigned_to_id
    remove_column :order_comments, :status
  end
end

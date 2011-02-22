class AddCommentsToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :commission_agent_comments, :text, :default => '', :null => false
    add_column :orders, :commission_subagent_comments, :text, :default => '', :null => false
  end

  def self.down
    remove_column :orders, :commission_agent_comments
    remove_column :orders, :commission_subagent_comments
  end
end

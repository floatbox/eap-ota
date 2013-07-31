class RemoveNotNullFromOrderAgentCommission < ActiveRecord::Migration
  def up
    change_column :orders, :commission_agent_comments, :string, :null => true
    change_column :orders, :commission_subagent_comments, :string, :null => true
  end

  def down
    change_column :orders, :commission_subagent_comments, :string, :null => false
    change_column :orders, :commission_agent_comments, :string, :null => false
  end
end

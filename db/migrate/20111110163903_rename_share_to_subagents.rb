class RenameShareToSubagents < ActiveRecord::Migration
  def up
    change_table :orders do |t|
      t.decimal :price_agent, :precision => 9, :scale => 2, :default => 0.0, :null => false
      t.decimal :price_subagent, :precision => 9, :scale => 2, :default => 0.0, :null => false
    end
    execute "update orders set price_subagent = price_share"

    change_table :tickets do |t|
      t.decimal :price_agent, :precision => 9, :scale => 2, :default => 0.0, :null => false
      t.decimal :price_subagent, :precision => 9, :scale => 2, :default => 0.0, :null => false
    end
    execute "update tickets set price_subagent = price_share"
  end
end

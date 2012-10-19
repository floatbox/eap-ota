class RemoveActionFromVersions < ActiveRecord::Migration
  def up
    remove_column :versions, :action
  end

  def down
    add_column :versions, :action, :string
  end
end

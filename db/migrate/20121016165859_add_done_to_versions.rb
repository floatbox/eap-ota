class AddDoneToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :done, :string
    execute "update versions set done = action"
  end
end

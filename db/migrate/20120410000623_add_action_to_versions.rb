class AddActionToVersions < ActiveRecord::Migration
  def change
    change_table :versions do |t|
      t.string :action
    end
  end
end

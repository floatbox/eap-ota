class AddRolesToDeckUser < ActiveRecord::Migration
  def change
    add_column :deck_users, :roles, :string, null: false, default: ""
  end
end

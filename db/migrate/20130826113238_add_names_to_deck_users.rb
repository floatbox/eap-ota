class AddNamesToDeckUsers < ActiveRecord::Migration
  def change
    add_column :deck_users, :first_name, :string, :default => "", :null => false
    add_column :deck_users, :last_name, :string, :default => "", :null => false
    add_column :deck_users, :locked_at, :datetime
  end
end

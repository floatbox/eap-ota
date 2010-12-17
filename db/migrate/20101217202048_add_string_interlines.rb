class AddStringInterlines < ActiveRecord::Migration
  def self.up
    add_column :airlines, :interlines, :string, :null => false, :default => ''
  end

  def self.down
    remove_column :airlines, :interlines
  end
end

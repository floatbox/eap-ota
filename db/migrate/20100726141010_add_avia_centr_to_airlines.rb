class AddAviaCentrToAirlines < ActiveRecord::Migration
  def self.up
    change_table :airlines do |t|
      t.boolean :aviacentr, :default => false, :null => false
    end
  end

  def self.down
    remove_column :airlines, :aviacentr
  end
end

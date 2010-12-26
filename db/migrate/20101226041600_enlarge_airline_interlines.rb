class EnlargeAirlineInterlines < ActiveRecord::Migration
  def self.up
    change_table :airlines do |t|
      t.remove :interlines
      t.text :interlines, :default => "", :null => false
    end
  end

  def self.down
    change_table :airlines do |t|
      t.remove :interlines
      t.string :interlines, :default => "", :null => false
    end
  end
end

class AddOfficeToAmadeusSession < ActiveRecord::Migration
  def self.up
    change_table :amadeus_sessions do |t|
      t.string :office, :default => '', :null => false
    end
  end

  def self.down
    remove_column :amadeus_sessions, :office
  end
end

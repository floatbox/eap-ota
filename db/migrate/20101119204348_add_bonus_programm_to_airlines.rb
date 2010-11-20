class AddBonusProgrammToAirlines < ActiveRecord::Migration
  def self.up
    add_column :airlines, :bonus_program_name, :string
  end

  def self.down
    remove_column :airlines, :bonus_program_name
  end
end

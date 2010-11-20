class CreateAirlineAllianceModel < ActiveRecord::Migration
  def self.up
    create_table :airline_alliances do |t|
      t.string :name, :null => false
      t.string :bonus_program_name
    end
    add_column :airlines, :airline_alliance_id, :integer
  end

  def self.down
    remove_column :airlines, :airline_alliance_id
    drop_table :airline_alliances
  end
end

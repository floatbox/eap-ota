class AddGdsAndContibutors < ActiveRecord::Migration
  def self.up
    create_table :global_distribution_systems do |t|
      t.string  :name
    end
    create_table :consolidators do |t|
      t.string :name
      t.string :booking_office
      t.string :ticketing_office
    end
    add_column :airlines, :gds_id, :integer
    add_column :airlines, :consolidator_id, :integer
  end

  def self.down
    drop_table :global_distribution_systems
    drop_table :consolidators
    remove_column :airlines, :gds_id
    remove_column :airlines, :consolidator_id
  end
end

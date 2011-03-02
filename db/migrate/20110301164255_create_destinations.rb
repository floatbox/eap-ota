class CreateDestinations < ActiveRecord::Migration
  def self.up
    create_table :destinations do |t|
      t.integer :to_id, :nil => false
      t.integer :from_id, :nil => false
      t.boolean :rt
      t.timestamps
    end
  end

  def self.down
    drop_table :destinations
  end
end


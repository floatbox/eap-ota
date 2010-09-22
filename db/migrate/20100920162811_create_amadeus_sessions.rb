class CreateAmadeusSessions < ActiveRecord::Migration
  def self.up
    create_table :amadeus_sessions do |t|
      t.string :token, :null => false
      t.integer :seq, :null => false
      t.integer :booking

      t.timestamps
    end
  end

  def self.down
    drop_table :amadeus_sessions
  end
end

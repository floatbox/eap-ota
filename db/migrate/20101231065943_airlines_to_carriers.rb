class AirlinesToCarriers < ActiveRecord::Migration
  def self.up
    rename_table "airlines", "carriers"
  end

  def self.down
    rename_table "carriers", "airlines"
  end
end

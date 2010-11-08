class RemoveAmadeusCommission < ActiveRecord::Migration
  def self.up
    drop_table "amadeus_commissions"
  end

  def self.down
    create_table "amadeus_commissions" do |t|
      t.integer  "airline_id"
      t.float    "value",      :default => 0.0,   :null => false
      t.boolean  "percentage", :default => false, :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end

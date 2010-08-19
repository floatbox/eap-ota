class CreateAmadeusCommissions < ActiveRecord::Migration
  def self.up
    create_table :amadeus_commissions do |t|
      t.references :airline
      t.float :value, :null => false, :default => 0.0
      t.boolean :percentage, :null => false, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :amadeus_commissions
  end
end

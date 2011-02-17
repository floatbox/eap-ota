class CreateHotOffers < ActiveRecord::Migration
  def self.up
    create_table :hot_offers do |t|
      t.string :code, :null => false
      t.string :url, :null => false
      t.string :description, :null => false
      t.integer :price, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :hot_offers
  end
end

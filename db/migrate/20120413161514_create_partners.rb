class CreatePartners < ActiveRecord::Migration
  def self.up
    create_table :partners do |t|
      t.string :token, :null => false
      t.string :password, :null => false
      t.boolean :enabled, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :partners
  end
end

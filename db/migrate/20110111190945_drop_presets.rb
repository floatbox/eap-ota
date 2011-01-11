class DropPresets < ActiveRecord::Migration
  def self.up
    drop_table :presets
  end

  def self.down
    create_table "presets" do |t|
      t.string   "name"
      t.text     "query"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end

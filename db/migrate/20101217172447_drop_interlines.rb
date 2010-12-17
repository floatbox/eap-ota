class DropInterlines < ActiveRecord::Migration
  def self.up
    drop_table :interline_agreements
  end

  def self.down
    create_table "interline_agreements", :id => false do |t|
      t.integer "company_id", :null => false
      t.integer "partner_id", :null => false
    end
  end
end

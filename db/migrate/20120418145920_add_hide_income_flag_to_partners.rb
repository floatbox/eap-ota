class AddHideIncomeFlagToPartners < ActiveRecord::Migration
  def self.up
    change_table :partners do |t|
      t.boolean :hide_income, :null => false
    end
  end

  def self.down
    remove_column :partners, :hide_income
  end
end

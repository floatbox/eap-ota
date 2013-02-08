class AddCheatToPartners < ActiveRecord::Migration
  def change
    add_column :partners, :cheat, :boolean, :default => false
  end
end

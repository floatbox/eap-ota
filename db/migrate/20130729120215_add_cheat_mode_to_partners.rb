class AddCheatModeToPartners < ActiveRecord::Migration
  def change
    add_column :partners, :cheat_mode, :string, :default => 'no'
  end
end

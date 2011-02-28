class RenameContinentRuToContinentInCountries < ActiveRecord::Migration
  def self.up
    rename_column :countries, :continent_ru, :continent
  end

  def self.down
    rename_column :countries, :continent, :continent_ru
  end
end

class AddSynonymListToRegions < ActiveRecord::Migration
  def self.up
    add_column :regions, :synonym_list, :string
  end

  def self.down
    remove_column :regions, :synonym_list
  end
end


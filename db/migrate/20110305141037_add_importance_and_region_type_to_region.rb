class AddImportanceAndRegionTypeToRegion < ActiveRecord::Migration
  def self.up
    add_column :regions, :importance, :integer, :default => 0
    add_column :regions, :region_type, :string
  end

  def self.down
    remove_column :regions, :importance
    remove_column :regions, :region_type
  end
end


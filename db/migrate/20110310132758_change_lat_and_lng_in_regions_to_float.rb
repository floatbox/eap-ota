class ChangeLatAndLngInRegionsToFloat < ActiveRecord::Migration
  def self.up
    change_column :regions, :lat, :float
    change_column :regions, :lng, :float
  end

  def self.down
    change_column :regions, :lat, :string
    change_column :regions, :lng, :string
  end
end


class AddSearchAroundFieldToCities < ActiveRecord::Migration
  def self.up
    add_column :cities, :search_around, :boolean
  end

  def self.down
    remove_column  :cities, :search_around
  end
end


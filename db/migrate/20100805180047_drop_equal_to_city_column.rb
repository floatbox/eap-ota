class DropEqualToCityColumn < ActiveRecord::Migration
  def self.up
    remove_column :airports, :equal_to_city
  end

  def self.down
    add_column :airports, :equal_to_city, :boolean
  end
end


class AddSomeFieldsToRegions < ActiveRecord::Migration
  def self.up
    [:morpher_to, :morpher_from, :morpher_in, :proper_to, :proper_from, :proper_in, :lat, :lng].each do |m|
      add_column :regions, m, :string
    end

  end

  def self.down
    [:morpher_to, :morpher_from, :morpher_in, :proper_to, :proper_from, :proper_in, :lat, :lng].each do |m|
      remove_column :regions, m
    end
  end
end


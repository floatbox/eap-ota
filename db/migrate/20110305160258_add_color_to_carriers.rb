class AddColorToCarriers < ActiveRecord::Migration
  def self.up
    add_column :carriers, :color, :string
  end

  def self.down
    remove_colum :carriers, :color
  end
end


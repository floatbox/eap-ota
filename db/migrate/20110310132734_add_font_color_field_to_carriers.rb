class AddFontColorFieldToCarriers < ActiveRecord::Migration
  def self.up
    add_column :carriers, :font_color, :string
  end

  def self.down
    remove_column :carriers, :font_color, :string
  end
end


class AddCodeAndDescriptionFieldsToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :code, :string
    add_column :orders, :description, :string
  end

  def self.down
    add_column :orders, :code
    add_column :orders, :description
  end
end


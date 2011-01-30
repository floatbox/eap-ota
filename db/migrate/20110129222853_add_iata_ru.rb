class AddIataRu < ActiveRecord::Migration
  def self.up
    add_column :cities, :iata_ru, :string
    add_column :cities, :sirena_name, :string
    add_column :airports, :iata_ru, :string
    add_column :airports, :sirena_name, :string
  end

  def self.down
    remove_column :cities, :iata_ru
    remove_column :cities, :sirena_name
    remove_column :airports, :iata_ru
    remove_column :airports, :sirena_name
  end
end

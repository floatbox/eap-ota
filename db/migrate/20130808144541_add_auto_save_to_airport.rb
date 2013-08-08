class AddAutoSaveToAirport < ActiveRecord::Migration
  def change
    add_column :airports, :auto_save, :boolean, default: false, null: false
  end
end

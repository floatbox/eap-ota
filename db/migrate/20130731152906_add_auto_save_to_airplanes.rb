class AddAutoSaveToAirplanes < ActiveRecord::Migration
  def change
    add_column :airplanes, :auto_save, :boolean, null: false, default: false
  end
end

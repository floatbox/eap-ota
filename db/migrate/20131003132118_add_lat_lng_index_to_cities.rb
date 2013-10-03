class AddLatLngIndexToCities < ActiveRecord::Migration
  def change
    add_index :cities, [:lat, :lng]
  end
end

class AddSourceToFlightGroups < ActiveRecord::Migration
  def change
    add_column :flight_groups, :source, :string, :null => false, :blank => false
  end
end


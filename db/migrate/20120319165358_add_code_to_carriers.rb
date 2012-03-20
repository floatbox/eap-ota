class AddCodeToCarriers < ActiveRecord::Migration
  def change
    add_column :carriers, :code, :string
  end
end

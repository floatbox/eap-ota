class AddIndexToPartners < ActiveRecord::Migration
  def change
    add_index :partners, [:token]
  end
end

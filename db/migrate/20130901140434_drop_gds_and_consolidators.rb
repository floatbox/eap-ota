class DropGdsAndConsolidators < ActiveRecord::Migration
  def up
    drop_table :global_distribution_systems
    drop_table :consolidators
    remove_column :carriers, :consolidator_id
    remove_column :carriers, :gds_id
  end
end

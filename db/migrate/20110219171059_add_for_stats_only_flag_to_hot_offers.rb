class AddForStatsOnlyFlagToHotOffers < ActiveRecord::Migration
  def self.up
    add_column :hot_offers, :for_stats_only, :boolean
  end

  def self.down
    remove_column :hot_offers, :for_stats_only
  end
end

class AddDatesToHotOffer < ActiveRecord::Migration
  def change
    add_column :hot_offers, :date1, :date
    add_column :hot_offers, :date2, :date
  end
end

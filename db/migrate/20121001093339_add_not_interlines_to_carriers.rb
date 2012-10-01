class AddNotInterlinesToCarriers < ActiveRecord::Migration
  def change
    change_table :carriers do |t|
      t.string :not_interlines
    end
  end
end

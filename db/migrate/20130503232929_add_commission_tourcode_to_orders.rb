class AddCommissionTourcodeToOrders < ActiveRecord::Migration
  def change
    change_table :orders do |t|
      t.string :commission_tour_code
    end
  end
end

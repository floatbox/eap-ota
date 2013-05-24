class AddCommissionDesignatorToOrders < ActiveRecord::Migration
  change_table :orders do |t|
    t.string :commission_designator
  end
end

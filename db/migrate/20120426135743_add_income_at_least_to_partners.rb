class AddIncomeAtLeastToPartners < ActiveRecord::Migration
  def change
    change_table :partners do |t|
      t.integer :income_at_least
    end
  end
end

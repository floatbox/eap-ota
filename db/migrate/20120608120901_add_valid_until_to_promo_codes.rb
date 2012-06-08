class AddValidUntilToPromoCodes < ActiveRecord::Migration
  def change
    add_column :promo_codes, :valid_until, :date, :null => false
  end
end

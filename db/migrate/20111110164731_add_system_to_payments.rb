class AddSystemToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :system, :string
  end
end

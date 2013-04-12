class CreateImportsPayments < ActiveRecord::Migration
  def change
    create_table :imports_payments, :id => false do |t|
      t.references :import
      t.references :payment
    end
    add_index :imports_payments, [:import_id, :payment_id]
  end
end

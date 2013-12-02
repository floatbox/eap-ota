class CreateCustomerInstructions < ActiveRecord::Migration
  def change
    create_table :customer_instructions do |t|
      t.string :status
      t.string :email
      t.string :format
      t.string :subject
      t.text :message
      t.references :customer, index: true
      t.timestamps
    end
    add_index :customer_instructions, :customer_id
  end
end

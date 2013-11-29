class AddReasonToCustomerInstructions < ActiveRecord::Migration
  def change
    add_column :customer_instructions, :reason, :text
  end
end

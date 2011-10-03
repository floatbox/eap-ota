class AddSomeFieldsToTicketsForRefunds < ActiveRecord::Migration
  def change
    change_table :tickets do |t|
      t.column :kind, :string, :default => 'ticket'
      t.column :processed, :boolean, :default => false
      t.column :parent_id, :integer
    end
  end
end

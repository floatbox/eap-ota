class RemoveProcessedFlagFromTickets < ActiveRecord::Migration
  def up
    remove_column :tickets, :processed
  end

  def down
    add_column :tickets, :processed, :boolean, :default => true
  end
end

class AddCommentFieldToAirlines < ActiveRecord::Migration
  def self.up
    add_column :carriers, :comment, :text
  end

  def self.down
    remove_column :carriers, :comment
  end
end


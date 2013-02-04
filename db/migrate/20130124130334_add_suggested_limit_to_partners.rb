class AddSuggestedLimitToPartners < ActiveRecord::Migration
  def up
    add_column :partners, :suggested_limit, :integer
  end

  def down
    remove_column :partners, :suggested_limit
  end
end

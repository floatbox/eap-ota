class RenameIdOverrideToRefInPayments < ActiveRecord::Migration
  def self.up
    rename_column :payments, :id_override, :ref
  end

  def self.down
    rename_column :payments, :ref, :id_override
  end
end

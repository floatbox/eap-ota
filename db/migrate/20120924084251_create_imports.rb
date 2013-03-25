class CreateImports < ActiveRecord::Migration
  def up
    create_table :imports do |t|
      t.string :md5
      t.string :kind
      t.integer :pass
      t.string :filename
      t.binary :content
      t.timestamps
    end
    add_index :imports, :md5, :unique => true
  end

  def down
    drop_table :imports
  end
end

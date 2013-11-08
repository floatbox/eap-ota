class CreateDeckSms < ActiveRecord::Migration
  def up
    create_table :deck_sms, options: 'DEFAULT CHARSET=utf8' do |t|
      t.string      :message, null: false
      t.datetime    :sent_at
      t.datetime    :received_at
      t.string      :status, default: 'composed', null: false
      t.string      :address, null: false

      t.integer     :provider_id
      # можно при нужде мигрировать в отдельную таблицу или дропнуть колонку
      # возможно будет несколько провайдеров
      t.string      :provider

      t.timestamps
    end

    add_index :deck_sms, :status
    add_index :deck_sms, [:provider, :provider_id], unique: true

    execute 'ALTER TABLE deck_sms AUTO_INCREMENT = 1000;'
  end

  def down
    drop_table :deck_sms
  end
end


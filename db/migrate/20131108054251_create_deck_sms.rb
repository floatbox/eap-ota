class CreateDeckSMS < ActiveRecord::Migration
  def up
    create_table :deck_sms do |t|
      t.string      :message
      t.datetime    :sent_at
      t.datetime    :received_at
      t.string      :status
      t.string      :address

      t.integer     :provider_id
      # можно при нужде мигрировать в отдельную таблицу или дропнуть колонку
      # возможно будет несколько провайдеров
      t.string      :provider

      t.timestamps
    end

    add_index :deck_sms, :status
    add_index :deck_sms, [:provider, :provider_id], unique: true

    # для справки
    # изменение значения авто-инкремента будет использовано для clientId
    execute 'ALTER TABLE deck_sms AUTO_INCREMENT = 10;'
  end

  def down
    drop_table :deck_sms
  end
end


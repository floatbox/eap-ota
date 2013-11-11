# encoding: utf-8

class Deck::SMS < ActiveRecord::Base
  set_table_name :deck_sms
  attr_accessible :status, :message, :address, :provider_id, :error_message

  validate :status, presence: true
  validate :address, presence: true
  validate :message, presence: true, allow_blank: false, sms: true

  def initialize *args
    # всегда проставляем статус 'composed' для новых сообщений
    # статус означает что сообщение составлено, т.к. message обязателен
    @status = 'composed'
    super
  end

  def send_to_provider(params = {})
    # возможно следует убрать проверку на persisted? отсюда
    # или бросать исключение, пока не понял
    if persisted?
      params = {
        client_id: id,
        address: address,
        content: message,
        start_time: Time.now,
      }.merge(params)

      if info = ::SMS::MFMS.new.send_sms(params)[id.to_s]
        code = info[:code]
        status = code == 'ok' ? 'processing' : 'failure'
        update_attributes(
          provider_id: info[:provider_id],
          error_message: code,
          status: status
        )
      end
    end
    nil
  rescue ::SMS::Base::SMSError => e
    with_warning(e)
    update_attributes status: 'failure'
    nil
  end


end


# encoding: utf-8

class Deck::SMS < ActiveRecord::Base
  set_table_name :deck_sms

  attr_accessible :status, :message, :address, :error_message, :provider, :provider_id, :sent_at

  attr_default :status, 'composed' # см #sent?

  validate :status, presence: true
  validate :address, presence: true
  validate :message, presence: true, allow_blank: false, sms: true

  # добавляет интерфейс к гейту
  include ::SMS

  def delivery_confirmed?
    # сообщение проходит следующие статусы:
    # composed - составленно, может быть отправлено
    # sent - отправлено провайдеру на отправку
    # confirmed - отправка подтверждена провайдером
    # failure - ошибка по какой-нибудь причине, подробности в error_message
    status == 'confirmed'
  end

  # доставляет текущее сообщение
  # отправлять можно только сохраненные в базе сообщения
  def deliver(params = {})
    # возможно следует убрать проверку на persisted? отсюда
    # или бросать исключение, пока не понял
    if persisted?
      params = merge_params(params)
      if info = gate.deliver_sms(params)[id.to_s]
        update_with_info(info, params)
        info
      end
    end
    nil
  rescue ::SMS::Base::SMSError => e
    with_warning(e)
    update_attributes status: 'failure'
    nil
  end

  def update_delivery_status!
    if persisted?
      info = gate.check_delivery(id)[id.to_s]
      attrs = {}
      if info[:code] == 'ok'
        update_attributes(status: 'confirmed')
      else
        update_attributes(status: 'unconfirmed', error_message: "#{info[:code]}: #{info[:error]}")
      end
    end
    nil
  rescue ::SMS::Base::SMSError => e
    # сфейлился весь запрос, а не одиночные сообщения
    # ставим все в статус failure
    with_warning(e)
    update_attributes(status: 'unconfirmed', error_message: "can't confirm")
    nil
  end


  # доставляет пачку сообщений, одним запросом к провайдеру смс
  def self.mass_deliver(messages, common = {})
    # Array of Deck::SMS
    messages = messages.map { |m| m.merge_params(common: common) }

    gate.deliver_sms(messages).map do |sms_id, info|
      sms = Deck::SMS.find(sms_id)
      sms.update_with_info(info, params)
      info
    end
    nil
  rescue ::SMS::Base::SMSError => e
    # сфейлился весь запрос, а не одиночные сообщения
    # ставим все в статус failure
    with_warning(e)
    messages.map { |m| m.update_attributes(status: 'failure') }
    nil
  end

  def merge_params(params)
    provider = gate.class.to_s.split('::').last.downcase

    ActiveSupport::HashWithIndifferentAccess.new(
      {
        client_id: id,
        address: address,
        content: message,
        start_time: Time.now,
        # можно оставлять тут, пока не появится другого провайдера
        # а не пригодится - можно будет колонку просто выпилить
        provider: provider
      }.merge(params)
    )
  end

  def update_with_info(info, params)
    code = info[:code]
    status = code == 'ok' ? 'sent' : 'failure'
    update_attributes(
      provider_id: info[:provider_id],
      error_message: code,
      status: status,
      sent_at: params[:start_time],
      provider: params[:provider],
    )
  end

end


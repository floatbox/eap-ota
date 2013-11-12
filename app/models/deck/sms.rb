# encoding: utf-8

class Deck::SMS < ActiveRecord::Base
  set_table_name :deck_sms

  attr_accessible :status, :message, :address, :error_message, :provider, :provider_id

  attr_default :status, 'composed' # см #sent?

  validate :status, presence: true
  validate :address, presence: true
  validate :message, presence: true, allow_blank: false, sms: true

  # добавляет интерфейс к гейту
  include ::SMS

  def sent?
    # сообщение проходит следующие статусы:
    # composed - составленно, может быть отправлено
    # sent - отправлено провайдеру на отправку
    # confirmed - отправка подтверждена провайдером
    # failure - ошибка по какой-нибудь причине, подробности в error_message
    #
    # FIXME переименовать статус sent,
    # чтобы не было путаницы
    status == 'confirmed'
  end

  # доставляет текущее сообщение
  def deliver(params = {})
    # возможно следует убрать проверку на persisted? отсюда
    # или бросать исключение, пока не понял
    if persisted?
      params = merge_params(params)
      if info = gate.send_sms(params)[id.to_s]
        update_with_info(info)
        info
      end
    end
    nil
  rescue ::SMS::Base::SMSError => e
    with_warning(e)
    update_attributes status: 'failure'
    nil
  end

  # доставляет пачку сообщений, одним запросом к провайдеру смс
  def self.mass_deliver(messages, common = {})
    # Array of Deck::SMS
    messages = messages.map { |m| m.merge_params(common: common) }

    gate.send_sms(messages).map do |sms_id, info|
      sms = Deck::SMS.find(sms_id)
      sms.update_with_info(info)
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
        provider: provider,
      }.merge(params)
    )
  end

  def update_with_info(info)
    code = info[:code]
    status = code == 'ok' ? 'sent' : 'failure'
    update_attributes(
      provider_id: info[:provider_id],
      error_message: code,
      status: status
    )
  end

end


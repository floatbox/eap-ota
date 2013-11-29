# encoding: utf-8

class Rapida
  # класс для работы с RapidaCharge и всем-всем-всем

  def initialize(txn_id, account, price, phone)
    @txn_id = txn_id
    @account = account
    @price = (price && BigDecimal.new(price))
    @phone = phone
  end

  # основные обработчики

  def check
    params = if checkable?
      # создает платеж со статусом pending
      #create_pending_charge!
      {
        result: error_code(:ok),
        txn_id: @txn_id,
        account: @account,
      }
    else
      params = {}
    end
    builder = Builder.new params
    builder.check_response
    # заглушка
    'check'
  end

  def pay
    # заглушка
    'pay'
  end

  def unknown_command

  end

  # /основные обработчики

  private

  # операции с платежами

  def create_pending_payment!
    @order.payment << RapidaCharge.create(status: 'pending', their_ref: @txn_id)
  end

  # /операции с платежами


  # проверки состояния платежа и заказа

  # проставлять @error и @comment можно как внутри valid?, так и внутри @checkable? и @payable?

  def checkable?
    # проверяет, можно ли вернуть check без ошибки
    order? && @order.pending? && valid?
  end

  def payable?
  end

  def order?
    @order ||= Order.where(code: @account).first ? true : false
  end

  # общие проверки для check и pay
  def valid?
    !!(
      insufficient_params? ||
      inadequate_price?
    )
  end

  def insufficient_params?
    [:txn_id, :account, :price, :phone].each do |attr|
      # есть небольшая проблема с несоответствием названия sum/price,
      # но не думаю что это очень важно и требует переименования
      unless instance_variable_get(:"@#{attr}")
        @error = :denied_technically
        @comment = "отсутствует атрибут #{attr}"
        return true
      end
    end
    false
  end

  def inadequate_price?
    cmp = price <=> @order.price_with_payment_commission
    if cmp == 0
      false
    else
      @error = cmp > 0 ? :price_gt_needed : :price_lt_needed
      true
    end
  end

  # /проверки состояния платежа и заказа


  # ошибки, статус коды

  def error_code(error_type)
    case error_type
      # справа описания из документации рапиды
      when :ok                     then 0   # ОК
      when :temporary_error        then 1   # Временная ошибка. Повторите запрос позже.
      when :wrong_account          then 4   # Неверный формат идентификатора.
      when :unknown_account        then 5   # Идентификатор абонента не найден.
      when :denied_by_operator     then 7   # Прием платежа запрещен оператором.
      when :denied_technically     then 8   # Прием платежа запрещен по техническим причинам.
      when :paid_already           then 10  # Счет уже оплачен.
      when :bill_not_active        then 79  # Счет абонента не активен.
      when :price_lt_needed        then 241 # Сумма платежа слишком мала.
      when :price_gt_needed        then 242 # Сумма платежа слишком велика.
      when :uncheckable_bill       then 243 # Невозможно проверить состояние счета.
      when :other_operator_error   then 300 # Другая ошибка оператора.
      when :signature_error        then 500 # Ошибка подписи
      else fail "unknown rapida error: #{error_type}"
    end
  end

  def fatal?(query_type, error_code)
    # фатальность влияет на проведение рапидой повторных запросов
    # Фактически это означает, что если ошибка фатальная - запроса не последует.
    # NOTE 1) для расчета с ними возможно придется иметь в виду, что
    # > По истечении 120 минут и/или календарных суток любой результат воспринимается как успешный.
    # cудя по всему они проставляют успешные статусы по крону
    # NOTE 2) для запросов с command=pay не бывает фатальных ответов, если верить их табличке
    return true unless 0 && query_type == :check
    false
  end

  # / ошибки, статус коды

  class Builder
    # Отвечает исключительно за генерацию xml-ответов.
    # Все проверки должен делать класс Rapida.
    # FIXME возможно вынести отдельно надо будет, посмотрим насколько разрастется

    include KeyValueInit

    def check_response
      Nokogiri::XML::Builder.new(encoding: 'utf-8') do |xml|
        xml.response_ {
          xml.rapida_txn_id  @txn_id              # id рапиды
          xml.result_        @result              # 0 - ок, 1 - не ок
          xml.account_       @account if @account # идентификатор, переданный рапидой, равен Order#code
          xml.passangers_    @persons if @persons # пассажиры.to_s
          xml.trip_          @extra   if @extra   # экстра инфо, пока просто для галочки
          xml.shortinfo_     @info    if @info    # любые заметки
          xml.sum_           @price   if @price   # сумма платежа
          xml.debt_          @debt    if @debt    # сумма, оставшаяся к оплате - пока не используем
        }
      end
    end

    def pay_response
      Nokogiri::XML::Builder.new(encoding: 'utf-8') do |xml|
        xml.response_ {
          xml.rapida_txn_id  @txn_id              # id рапиды
          xml.result_        @result              # 0 - ок, 1 - не ок
          # FIXME
          # prv_txn:
          # > Уникальный номер операции пополнения баланса Потребителя.
          # > Этот элемент должен возвращаться после запроса на пополнение баланса.
          # > При запросе на проверку возможности осуществления Платежа, его возвращать не обязательно - он все равно не обрабатывается. 
          xml.prv_txn_       @pay_id  if @pay_id  # наш id судя по всему
          xml.comment_       @comment if @comment # кандидат на убиение
          xml.trip_          @extra   if @extra   # экстра инфо, пока просто для галочки
          # TODO переспросить насчет названия и этого тега
          xml.passangers_    @persons if @persons # пассажиры.to_s
          xml.receipt_       @receipt if @repeipt # линк на маршрутку
        }
      end
    end
  end

end


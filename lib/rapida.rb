# encoding: utf-8

class Rapida
  # класс для работы с RapidaCharge и всем-всем-всем

  def check(txn_id, account, price, phone)
    # TODO кастим параметры здесь, а не в контроллере
    #price = BigDecimal.new(price)
    # etc
    params = if checkable?(account, price)
      # заполнение параметров без ошибки
      # TODO обработка параметров
      {
        result: error_code(:ok)
      }
    else
      # заполнение параметров с ошибкой
      # TODO fill error params
      params = {}
    end
    builder = Builder.new params
    builder.check_response
    # заглушка
    'check'
  end

  def pay(txn_id, account, sum, phone)
    # заглушка
    'pay'
  end

  private

  # проверяет, можно ли вернуть check без ошибки
  def checkable?(account, price)
    order?(account) && @order.pending? && adequate_price?(price)
  end

  def adequate_price?(price)
    @order.price_with_payment_commission == price
  end

  def payable?(account)
  end

  # обязательно вызывать перед любой операцией с ордером
  def order?(account)
    @order = Order.where(code: account).first ? true : false
  end

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
          # TODO переспросить насчет названия и этого тега
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
        # TODO переспросить насчет названия, в доке написано respone - hopefully опечатка
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


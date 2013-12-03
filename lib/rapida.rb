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
    # создает платеж со статусом pending
    create_pending_payment! if checkable?

    info = @order && @order.full_info
    info = info && info.full_info[0...300] # длина до 300 символов
    route = @order && @order.route
    # сделать еще один запрос выглядит пока лучше, чем вычленять из full_info
    persons = Ticket.uniq.select([:first_name, :last_name, 'tickets.route']).joins(:order).where('orders.code = ?', 'lvj17l').join(&:name)

    builder = Builder.new result: error_code(error),
                          txn_id: @txn_id,
                          account: @account,
                          info: info,
                          trip: route,
                          persons: persons
    builder.check_response
  end

  def pay
    charge_payment! if payable?

    builder = Buider.new result: error_code(error),
                         txn_id: @txn_id,
                         account: @account,
                         info: @comment
    builder.pay_response
  end

  # /основные обработчики

  private

  # операции с платежами

  def create_pending_payment!
    payment = RapidaCharge.new
    payment.set_defaults
    payment.their_ref = @txn_id,
    payment.price = @price,
    payment.status = 'pending',
    @order.payments << payment
    @order.payments
  rescue ActiveRecord::StatementInvalid => e
    rescue_db_error(e)
  end

  def charge_payment!
    @order.update_attributes(
      payment_status: 'charged',
    )
  rescue ActiveRecord::StatementInvalid => e
    rescue_db_error(e)
  end

  def rescue_db_error(exception)
    # ловим ошибку при работе с базой,
    # т.к. сохранить платеж не получилось - отдаем код с "временной" ошибкой
    with_warning(exception)
    @error = :temporary_error
  end

  # /операции с платежами


  # проверки состояния платежа и заказа

  # проставлять @error и @comment можно внутри любого валидационного метода
  # более того, это делать обязательно, т.к. если @error остается пустым - возвращается код 0 ОК

  def checkable?
    # проверяет, можно ли вернуть check без ошибки
    valid_params? && order? && adequate_price?
  end

  def payable?
    valid_params? && pending? && adequate_price?
  end

  # TODO сделать стандартный генератор
  # методов типа "#{prefix_}#{status}?" для моделей
  def pending?
    order? && @order.payment_status == 'pending'
  end

  def order?
    if @order ||= Order.where(code: @account).first
      true
    else
      @error = :unknown_account
      false
    end
  end

  def valid_params?
    valid_account? && sufficient_params?
  end

  def sufficient_params?
    [:txn_id, :price].each do |attr|
      # есть небольшая проблема с несоответствием названия sum/price,
      # но не думаю что это очень важно и требует переименования
      unless instance_variable_get(:"@#{attr}")
        @error = :denied_technically
        @comment = "отсутствует атрибут #{attr}"
        return false
      end
    end
    true
  end

  def valid_account?
    valid = !!(/^\w{1,200}$/.match @account)
    @error = :wrong_account unless valid
    valid
  end

  def adequate_price?
    cmp = @price <=> @order.price_with_payment_commission
    if cmp == 0
      true
    else
      @error = cmp > 0 ? :price_gt_needed : :price_lt_needed
      false
    end
  end

  # /проверки состояния платежа и заказа


  # ошибки, статус коды

  def error
    @error || :ok
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

  # / ошибки, статус коды

  class Builder
    # Отвечает исключительно за генерацию xml-ответов.
    # Все проверки должен делать класс Rapida.
    # FIXME возможно вынести отдельно надо будет, посмотрим насколько разрастется

    include KeyValueInit
    attr_accessor :txn_id, :result, :account, :persons, :info, :trip, :price, :debt, :comment, :pay_id, :receipt

    def check_response
      Nokogiri::XML::Builder.new(encoding: 'utf-8') do |xml|
        xml.response_ {
          xml.rapida_txn_id  @txn_id              # id рапиды
          xml.result_        @result              # 0 - ок, 1 - не ок
          xml.account_       @account if @account # идентификатор, переданный рапидой, равен Order#code
          xml.passangers_    @persons if @persons # пассажиры.to_s
          xml.trip_          @trip    if @trip    # инфо по перелетам
          xml.shortinfo_     @info    if @info    # любые заметки
          xml.sum_           @price   if @price   # сумма платежа
          xml.debt_          @debt    if @debt    # сумма, оставшаяся к оплате - пока не используем
        }
      end.to_xml
    end

    def pay_response
      Nokogiri::XML::Builder.new(encoding: 'utf-8') do |xml|
        xml.response_ {
          xml.rapida_txn_id  @txn_id              # id рапиды
          xml.result_        @result              # 0 - ок, 1 - не ок
          # FIXME ?
          # prv_txn:
          # > Уникальный номер операции пополнения баланса Потребителя.
          # > Этот элемент должен возвращаться после запроса на пополнение баланса.
          xml.prv_txn_       @pay_id  if @pay_id  # наш id судя по всему
          xml.comment_       @comment if @comment # кандидат на убиение
          xml.trip_          @trip    if @trip    # инфо по перелетам
          xml.passangers_    @persons if @persons # пассажиры.to_s
          xml.receipt_       @receipt if @repeipt # линк на маршрутку
        }
      end.to_xml
    end
  end

end


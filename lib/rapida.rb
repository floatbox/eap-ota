# encoding: utf-8

class Rapida
  # класс для работы с RapidaCharge и всем-всем-всем

  def check(txn_id, account, sum, phone)
    # заглушка
    'check'
  end

  def pay(txn_id, account, sum, phone)
    # заглушка
    'pay'
  end

  private

  def order?(account)
    @order = Order.where(code: account).first ? true : false
  end

  def error
  end

  def fatal_error
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


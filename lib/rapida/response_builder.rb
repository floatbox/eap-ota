# encoding: utf-8

class Rapida::ResponseBuilder
  # Отвечает исключительно за генерацию xml-ответов.

  include KeyValueInit
  attr_accessor :txn_id, :result, :account, :persons, :info, :trip, :price, :debt, :comment, :pay_ref, :receipt

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
        xml.prv_txn_       @pay_ref             # ref нашего платежа
        xml.comment_       @comment if @comment # кандидат на убиение
        xml.trip_          @trip    if @trip    # инфо по перелетам
        xml.passangers_    @persons if @persons # пассажиры.to_s
        xml.receipt_       @receipt if @receipt # линк на маршрутку
      }
    end.to_xml
  end
end


# encoding: utf-8

class Rapida

  include Rapida::Error
  include Rapida::Validation

  def initialize(params)
    @txn_id = params[:txn_id]
    @account = params[:account]
    @price = params[:sum] && BigDecimal.new(params[:sum])
    @phone = params[:phone]
    @txn_date = params[:txn_date] && DateTime.strptime(params[:txn_date], '%Y%m%d%H%M%S')
  end

  # основные обработчики

  def check
    # создает платеж со статусом pending,
    # если в базе нет рапидовского платежа с their_ref = txn_id
    @mandatory_params = [:txn_id, :price]
    create_pending_payment! if checkable?
    helper = Rapida::Info.new(@order)

    builder = ResponseBuilder.new(
      result: error_code(error),
      txn_id: @txn_id,
      account: @account,
      info: helper.info,
      trip: helper.route,
      persons: helper.persons,
      price: @order.try(:price_with_payment_commission)
    )
    builder.check_response
  end

  def pay
    @mandatory_params = [:txn_id, :txn_date, :price]
    charge_payment! if payable?
    helper = Rapida::Info.new(@order)

    builder = ResponseBuilder.new(
      result: error_code(error),
      txn_id: @txn_id,
      pay_ref: @ref,
      price: @order.try(:price_with_payment_commission),
      persons: helper.persons,
      trip: helper.route,
      info: helper.info,
      receipt: '' # TODO починить ссылку на маршрутку
    )
    builder.pay_response
  end

  # /основные обработчики

  private

  # операции с платежами

  def create_pending_payment!
    payment = RapidaCharge.new
    payment.set_defaults
    payment.their_ref = @txn_id
    payment.price = @price
    payment.status = 'pending'
    @order.payments << payment
    @order.update_attributes(payment_status: 'pending')
    @order.payments
  rescue ActiveRecord::StatementInvalid => e
    rescue_db_error(e)
  end

  def charge_payment!
    payment = RapidaCharge.where(order_id: @order, their_ref: @txn_id).last
    @ref = payment.generate_ref
    payment.update_attributes(charged_on: @txn_date, ref: @ref)
    # FIXME? сохранять телефон кастомера
    @order.charge!
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

end


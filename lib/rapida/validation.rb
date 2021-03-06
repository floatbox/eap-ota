# encoding: utf-8

module Rapida::Validation
  # проверки состояния платежа и заказа

  # проставлять @error и @comment можно внутри любого валидационного метода
  # более того, это делать обязательно, т.к. если @error остается пустым - возвращается код 0 ОК

  def checkable?
    # проверяет, можно ли вернуть check без ошибки
    valid_params? && order? && !payment?
  end

  def payable?
    valid_params? && order? && payment?(:pay) && pending?
  end

  def payment?(method = :check)
    exists = RapidaCharge.where(order_id: @order, their_ref: @txn_id).count > 0
    if method == :pay
      @error = :uncheckable_bill unless exists
    end
    exists
  end

  # TODO сделать стандартный генератор
  # методов типа "#{prefix_}#{status}?" для моделей
  def pending?
    if order? && RapidaCharge.select(:status).where(order_id: @order, their_ref: @txn_id).last.not_secured?
      true
    else
      @error = :paid_already if @order.payments.last.secured?
      false
    end
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
    @mandatory_params.each do |attr|
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

end


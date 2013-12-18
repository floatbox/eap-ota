# encoding: utf-8

class Rapida::Info

  def initialize(order)
    @order = order
  end

  def persons
    # сделать еще один запрос выглядит пока лучше, чем вычленять из full_info
    Ticket.uniq.select([:first_name, :last_name]).joins(:order).where(order_id: @order).collect(&:name).join(', ')
  rescue ActiveRecord::StatementInvalid
    ''
  end

  def info
    info = @order.try(:full_info).to_s rescue ""
    refund_details = @order.try(:description).to_s rescue ""
    full = info + "\n" + refund_details
    # длина до 300 символов
    full[0...300]
  end

  def route
    @order.try(:route)
  end

end


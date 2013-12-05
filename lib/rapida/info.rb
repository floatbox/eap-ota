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
    # длина до 300 символов
    (@order && i = @order.full_info) ? i[0...300] : ''
  end

  def route
    @order && @order.route
  end

end

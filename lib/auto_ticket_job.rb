# encoding: utf-8
class AutoTicketJob

  def initialize(args={})
    @order_id = args[:order_id]
  end

  def perform
    order = Order.find(@order_id)
    order.do_auto_ticketing
  end

  def max_attempts
    1
  end

end

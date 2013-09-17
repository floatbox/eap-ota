# encoding: utf-8
class AutoTicketJob

  def initialize(args={})
    @order_id = args[:order_id]
  end

  def perform
    Order.transaction do
      order = Order.find(@order_id)
      if order.ok_to_auto_ticket?
        order.strategy.ticket
        order.ticket! || LoadTicketsJob.new(:order_id => order.id).delay
      end
    end
  end

  def max_attempts
    1
  end

end

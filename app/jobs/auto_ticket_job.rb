# encoding: utf-8
class AutoTicketJob

  def initialize(args={})
    @order_id = args[:order_id]
  end

  def perform
    @order = Order.find(@order_id)
    if @order.ok_to_auto_ticket?
      Delayed::Worker.logger.info  "starting AutoTicketJob for #{@order.pnr_number}"
      PaperTrail.controller_info = {:done => 'AutoTicketJob'}
      @order.strategy.ticket
      @order.ticket! || LoadTicketsJob.new(:order_id => @order.id).delay(queue: 'autoticketing')
      Delayed::Worker.logger.info "finished AutoTicketJob for #{@order.pnr_number}"
    end
  rescue Strategy::TicketError => e
    raise $!, "#{$!} (#{@order && @order.pnr_number})", $!.backtrace
  end

  def max_attempts
    1
  end

  def failure(job)
    order = Order.find @order_id
    order.update_attributes :ticket_status => 'error_ticket'
  end

end

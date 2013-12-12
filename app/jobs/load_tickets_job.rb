# encoding: utf-8
class LoadTicketsJob

  def initialize(args={})
    @order_id = args[:order_id]
  end

  def perform
    order = Order.find(@order_id)
    PaperTrail.controller_info = {:done => 'LoadTicketsJob'}
    return unless order.ticket_status == 'processing_ticket'
    Delayed::Worker.logger.add(Logger::INFO, "starting LoadTicketsJob for #{order.pnr_number}")
    raise "Не загрузились билеты (#{order.pnr_number})" unless order.ticket!
    Delayed::Worker.logger.add(Logger::INFO, "finished LoadTicketsJob for #{order.pnr_number}")
  end

  def delay(args={})
    Delayed::Job.enqueue(self, {
      # не уверен что для этого следует заводить еще одну очередь
      queue: 'autoticketing',
      priority: 0,  # самый высокий приоритет, дефолтный
      run_at: 3.minutes.from_now#, # если надо отложить первый старт
    }.merge(args))
  end

  def max_attempts
    6
  end

  def reschedule_at(now, attempts)
    now + 180 # seconds
  end

  def failure(job)
    order = Order.find @order_id
    order.update_attributes :ticket_status => 'error_ticket'
  end

end

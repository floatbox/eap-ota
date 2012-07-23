# encoding: utf-8
class LoadTicketsJob

  def initialize(args={})
    @order_id = args[:order_id]
  end

  def perform
    order = Order.find(@order_id)
    raise 'Не загрузились билеты' if order.ticket_status == 'ticketing' && !order.ticket!
  end

  def delay(args={})
    Delayed::Job.enqueue(self, {
      # queue: 'messaging',
      # priority: 0,  # самый высокий приоритет, дефолтный
      run_at: 5.minutes.from_now#, # если надо отложить первый старт
    }.merge(args))
  end

  def reschedule_at(now, attempts)
    now + 300 # seconds
  end

  def failure(job)
    order = Order.find @order_id
    order.update_attribute :ticket_status, 'error_ticket'
  end

end

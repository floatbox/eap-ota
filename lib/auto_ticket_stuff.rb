# encoding: utf-8
module AutoTicketStuff

  def calculated_auto_ticket
    Conf.site.auto_ticketing['enabled'] &&
      (Conf.site.auto_ticketing['exclude_list'][commission_ticketing_method].to_a.exclude?(commission_carrier)) &&
      payment_type == 'card' &&
      ticket_status == 'booked' &&
      !offline_booking
  end

  def do_auto_ticketing
    if auto_ticket &&
        calculated_auto_ticket &&
        ['blocked', 'charged'].include?(payment_status)
      strategy.ticket
      ticket! || LoadTicketsJob.new(:order_id => id).delay
    else
      update_attributes(auto_ticket: false)
    end
  rescue
    update_attributes(auto_ticket: false)
  end

  def create_auto_ticket_job
    Delayed::Job.enqueue AutoTicketJob.new(order_id: id), run_at: 30.minutes.from_now
  end

end

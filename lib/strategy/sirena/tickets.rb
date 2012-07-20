# encoding: utf-8
module Strategy::Sirena::Tickets

  def get_tickets
    order_resp = sirena.order(@order.pnr_number, @order.sirena_lead_pass)
    ticket_dates = sirena.pnr_status(@order.pnr_number).tickets_with_dates
    tickets = (order_resp.ticket_hashes.map do |t|
      t['ticketed_date'] = ticket_dates[t[:number]] if ticket_dates[t[:number]]
      t['ticketed_date'] ||= @order.created_at.to_date
      t.merge!({:validating_carrier => @order.commission_carrier})
      t
    end)
    tickets
  end

  def delayed_ticketing?
    # временная затычка, чтоб 3ds не пытался обилетить "ручное бронирование" и обломаться
    return true if @order.offline_booking?
    false
  end

  def ticket
    payment_confirm = sirena.payment_ext_auth(:confirm, @order.pnr_number, @order.sirena_lead_pass,
                                      :cost => (@order.price_fare + @order.price_tax))
    if payment_confirm.success?
      logger.info "Strategy::Sirena: ticketed succesfully"
      @order.ticket!
      return true
    else
      logger.error "Strategy::Sirena: ticketing error: #{payment_confirm.error}"
      cancel
      return false
    end
  end

end

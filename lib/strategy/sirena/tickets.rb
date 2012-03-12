# encoding: utf-8
module Strategy::Sirena::Tickets

  def get_tickets
    order_resp = sirena.order(@order.pnr_number, @order.sirena_lead_pass)
    ticket_dates = sirena.pnr_status(@order.pnr_number).tickets_with_dates
    tickets = (order_resp.ticket_hashes.map do |t|
      t['ticketed_date'] = ticket_dates[t[:number]] if ticket_dates[t[:number]]
      t.merge!({:processed => true, :validating_carrier => @order.commission_carrier})
      t
    end)
    tickets
  end

end

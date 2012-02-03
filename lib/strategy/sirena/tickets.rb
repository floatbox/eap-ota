# encoding: utf-8
module Strategy::Sirena::Tickets

  def get_tickets_and_dept_date
    order_resp = Sirena::Service.new.order(@order.pnr_number, @order.sirena_lead_pass)
    ticket_dates = Sirena::Service.new.pnr_status(@order.pnr_number).tickets_with_dates
    tickets = (order_resp.ticket_hashes.map do |t|
      t['ticketed_date'] = ticket_dates[t[:number]] if ticket_dates[t[:number]]
      t.merge!({:processed => true, :validating_carrier => @order.commission_carrier})
      t
    end)
    [tickets, order_resp.flights.first.dept_date]
  end

end

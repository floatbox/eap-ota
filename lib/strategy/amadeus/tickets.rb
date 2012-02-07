# encoding: utf-8
module Strategy::Amadeus::Tickets

  def get_tickets
    pnr_resp = prices = nil
    ::Amadeus.booking do |amadeus|
      pnr_resp = amadeus.pnr_retrieve(:number => @order.pnr_number)
      prices = amadeus.ticket_display_tst.prices_with_refs
      amadeus.pnr_ignore
    end
    tickets = []
    exchanged_tickets = pnr_resp.exchanged_tickets
    pnr_resp.tickets.deep_merge(prices).each do |k, ticket_hash|
      if ticket_hash[:number]
        if exchanged_tickets[k] && (exchanged_ticket = Ticket.where('code = ? AND number like ?', exchanged_tickets[k][:code], exchanged_tickets[k][:number] + '%').first)
          ticket_hash[:parent_id] = exchanged_ticket.id
          tickets << {:code => exchanged_ticket.code, :number => exchanged_ticket.number, :status => 'exchanged'}
        end

        if Ticket.office_ids.include? ticket_hash[:office_id]
          tickets << ticket_hash.merge({
            :processed => true,
            :source => 'amadeus',
            :pnr_number => @order.pnr_number,
            :commission_subagent => @order.commission_subagent.to_s
          })
        end
      end
    end

    tickets
  end

end

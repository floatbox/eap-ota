# encoding: utf-8
module Strategy::Amadeus::Tickets

  # FIXME обработать tst_resp.success? == false
  def get_tickets
    pnr_resp, tst_resp, prices = ()
    ::Amadeus.booking do |amadeus|
      pnr_resp = amadeus.pnr_retrieve(:number => @order.pnr_number)
      tst_resp = amadeus.ticket_display_tst
      prices = tst_resp.prices_with_refs
      amadeus.pnr_ignore
    end
    tickets = []
    exchanged_tickets = pnr_resp.exchanged_tickets
    pnr_resp.tickets.deep_merge(prices).each do |k, ticket_hash|
      if ticket_hash[:number]
        if exchanged_tickets[k]
          ticket_hash[:parent_number] = exchanged_tickets[k][:number]
          ticket_hash[:parent_code] = exchanged_tickets[k][:code]
        end

        tickets << ticket_hash.merge({
          :source => 'amadeus',
          :pnr_number => @order.pnr_number,
          :commission_subagent => @order.commission_subagent.to_s
        })
      end
    end

    tickets
  end

end

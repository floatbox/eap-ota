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

  def ticket
    # TODO сделать precheck на наличие и валидность комиссий в брони
    # Для выписки в американском офисе нужно убедится, что текуший офис - 2233
    raise Strategy::TicketError, 'Заказ не в состоянии booked' unless @order.ticket_status == 'booked'
    @order.update_attribute(:ticket_status, 'ticketing')
    case @order.commission_ticketing_method
    when 'aviacenter'
      amadeus_ticket('MOWR2233B')
    when 'direct'
      amadeus_ticket('MOWR228FA')
    when 'downtown'
      downtown_ticket
    else
      raise Strategy::TicketError, "unsupported ticketing method: #{@order.ticketing_method.inspect}"
    end
  rescue ::Amadeus::Error => e
    Airbrake.notify!(e)
    raise Strategy::TicketError, e.message
  end

  def amadeus_ticket(office_id)
    ::Amadeus.session(office_id) do |amadeus|
      amadeus.pnr_retrieve(:number => @order.pnr_number).or_fail!
      amadeus.doc_issuance_issue_ticket.or_fail!
    end
  end

  def downtown_ticket
    ::Amadeus.ticketing do |amadeus|

      # удаляем старый FM
      # TODO может, не добавлять FM при бронировании, а добавлять при выписке уже?

      # заодно открывает PNR
      pnr_text = amadeus.pnr_raw( @order.pnr_number )

      if m = pnr_text.match(/^ \s* (\d+) \s+ FM /x)
        amadeus.cmd("XE #{m[1]}")
      end

      # даем доступы для наших офисов
      # TODO может, при создании брони сразу вбивать оба офиса
      amadeus.cmd("ES/G MOWR2233B-B, MOWR228FA-B")

      # дальше полные права на американский офис,
      amadeus.cmd("RP/NYC1S21HX/ALL")

      amadeus.pnr_commit
    end

    # открываем в американском офисе.
    ::Amadeus.downtown do |amadeus|
      # пересчитываем маску: FXP (с валидирующим перевозчиком)
      amadeus.pnr_retrieve(:number => @order.pnr_number)

      # пересоздаем маску
      # TODO проверить новый тариф и оборвать выписку, если он существенно отличается?
      pricing = amadeus.fare_price_pnr_with_booking_class(:validating_carrier => @order.commission_carrier).or_fail!
      amadeus.ticket_create_tst_from_pricing(:fares_count => pricing.fares_count).or_fail!

      # для комиссионных билетов:

      # 12P для 12%, 5.50A для 5.50 USD
      commission = @order.commission_agent
      encoded_commission =
        if commission.percentage? && !commission.zero?
          "#{commission.rate}P"
        # if commission.usd?
        #   "#{commission.rate}A"
        else
          raise "выписка с комиссией #{commission} пока не поддерживается!"
        end

      amadeus.cmd("RMCOM*** CLAIM #{encoded_commission}")

      # если нужно не брать комиссию с детей или младенцев (зачем?)
      # RMCOM*** CLAIM 12P X/INF, CHD

      # вот эти ремарки могут понадобиться, но пока непонятно, в каких ситуациях
      ## TKT DESIGNATOR IF REQUIRED
      # RM COM*** TKT DSGN ...
      ## TOUR CODE IF REQUIRED
      # RM COM*** FT ...
      ## ENDORSEMENT IF ANY END IS REQUIRED
      # RM COM*** END ...

      # для некомиссионных билетов( agent_commission.zero? ):

      ## "Здесь подставляю размер сервисного сбора в зависимости от кол-ва пассажиров"
      # amadeus.cmd("RM COM*** CLAIM 0.00P")
      # amadeus.cmd("RM COM*** AGENT COM 0.00P")
      ## что такое @SF? какое-то форматирование?
      # amadeus.cmd("RM*MS98S*VCprocfe*TT11*TF<?SERV FEE AMOUNT@SF>*CM0*FPCHECK*pi")

      amadeus.cmd('RF WS')

      amadeus.pnr_commit_and_retrieve

      # отправить в очередь на выписку
      # вроде бы как, это закрывает текущий PNR
      # TODO заменить вызовом queue_place_pnr
      amadeus.cmd('QE/NYC1S211F/28C30')
    end
  end

end

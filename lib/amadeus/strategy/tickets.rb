# encoding: utf-8
module Amadeus::Strategy::Tickets


  # FIXME обработать tst_resp.success? == false
  def get_tickets
    pnr_resp, tst_resp, prices, baggage_with_refs = ()
    Amadeus.booking do |amadeus|
      pnr_resp = amadeus.pnr_retrieve(:number => @order.pnr_number)
      tst_resp = amadeus.ticket_display_tst
      prices = tst_resp.money_with_refs
      baggage_with_refs = tst_resp.baggage_with_refs
      amadeus.pnr_ignore
    end
    tickets = []
    exchanged_tickets = pnr_resp.exchanged_tickets
    add_number = pnr_resp.additional_pnr_numbers[@order.commission_carrier]
    # FIXME перенести обработку багажа в парсер ticket_display_tst или pnr_retrieve
    pnr_resp.tickets.deep_merge(prices).each do |k, ticket_hash|
      if ticket_hash[:number]
        if exchanged_tickets[k]
          ticket_hash[:parent_number] = exchanged_tickets[k][:number]
          ticket_hash[:parent_code] = exchanged_tickets[k][:code]
        end
        baggage_info = k[1].map do |seg_ref|
          if baggage_with_refs[k[0]] && baggage_with_refs[k[0]][seg_ref]
            baggage_with_refs[k[0]][seg_ref].serialize
          else
            BaggageLimit.new.serialize
          end
        end
        tickets << ticket_hash.merge({
          :source => 'amadeus',
          :baggage_info => baggage_info,
          :pnr_number => @order.pnr_number,
          :original_price_penalty => "0 RUB",
          :additional_pnr_number => add_number
        })
      end
    end
    pnr_resp.emd_tickets.each do |ticket_hash|
      tickets << ticket_hash.merge({
        :source => 'amadeus',
        :pnr_number => @order.pnr_number,
        :additional_pnr_number => add_number
      })
    end

    tickets
  end

  def ticket
    # TODO сделать precheck на наличие и валидность комиссий в брони
    # Для выписки в американском офисе нужно убедится, что текуший офис - 2233
    raise Strategy::TicketError, 'Заказ не в состоянии booked' unless @order.ticket_status == 'booked'
    @order.update_attributes :ticket_status => 'processing_ticket'
    add_to_visa_queue if @order.needs_visa_notification
    case @order.commission_ticketing_method
    when 'aviacenter'
      amadeus_ticket('MOWR2233B')
    when 'direct'
      amadeus_ticket('MOWR228FA')
    when 'downtown'
      downtown_ticket
    else
      raise Strategy::TicketError, "unsupported ticketing method: #{@order.commission_ticketing_method.inspect}"
    end
  rescue Amadeus::Error, Curl::Err::TimeoutError => e
    with_warning(e)
    @order.update_attributes(:ticket_status => 'error_ticket')
    raise Strategy::TicketError, e.message
  end

  def amadeus_ticket(office_id)
    Amadeus.session(office_id) do |amadeus|
      amadeus.pnr_retrieve(:number => @order.pnr_number).or_fail!
      # пересоздаем TST и сверяем цены
      # не выписываем, если цены изменились
      pricing = amadeus.fare_price_pnr_with_booking_class(:validating_carrier => @order.commission_carrier).or_fail!
      if pricing.prices != @order.prices
        amadeus.pnr_ignore
        raise Strategy::TicketError, "тариф или таксы изменились, было #{@order.prices.inspect}, стало #{pricing.prices.inspect}"
      else
        amadeus.ticket_create_tst_from_pricing(:fares_count => pricing.fares_count).or_fail!
        amadeus.pnr_commit_and_retrieve.or_fail!
      end
      amadeus.doc_issuance_issue_ticket.or_fail!

    end
  end

  def add_to_visa_queue
    # отправляем в очередь для получения данных о визе в америку
    Amadeus.ticketing do |amadeus|
      if @order.needs_visa_notification?
        amadeus.pnr_retrieve(:number => @order.pnr_number).or_fail!
        amadeus.cmd('QE8C21') if @order.needs_visa_notification?
      end
    end
  end

  def downtown_ticket
    Amadeus.ticketing do |amadeus|

      # заодно открывает PNR
      pnr_resp = amadeus.pnr_retrieve number: @order.pnr_number

      # удаляем старый FM
      # TODO может, не добавлять FM при бронировании, а добавлять при выписке уже?
      if fm_ref = pnr_resp.element_refs('FM').first
        amadeus.pnr_cancel( element: fm_ref ).or_fail!
      end

      # даем доступы для наших офисов
      # TODO может, при создании брони сразу вбивать оба офиса
      amadeus.pnr_add_multi_elements( full_access: ['MOWR2233B', 'MOWR228FA']).or_fail!

      # дальше полные права на американский офис,
      amadeus.cmd("RP/NYC1S21HX/ALL")

      amadeus.pnr_commit.or_fail!
    end

    # открываем в американском офисе.
    Amadeus.downtown do |amadeus|
      # пересчитываем маску: FXP (с валидирующим перевозчиком)
      amadeus.pnr_retrieve(:number => @order.pnr_number)

      # пересоздаем маску
      # TODO проверить новый тариф и оборвать выписку, если он существенно отличается?
      # unifares: точно false?
      pricing = amadeus.fare_price_pnr_with_booking_class(
        validating_carrier: @order.commission_carrier,
        unifares: false
      ).or_fail!
      amadeus.ticket_create_tst_from_pricing(:fares_count => pricing.fares_count).or_fail!

      # для комиссионных билетов:

      # 12P для 12%, 5.50A для 5.50 USD

      remarks = []
      remarks << "COM*** CLAIM " + encode_downtown_commission(@order.commission_agent)
      remarks << "COM*** AGENT COM " + encode_downtown_commission(@order.commission_subagent)

      # amadeus.cmd("RM COM*** AGENT COM 0.00P")
      # если нужно не брать комиссию с детей или младенцев (зачем?)
      # RMCOM*** CLAIM 12P X/INF, CHD

      ## TKT DESIGNATOR IF REQUIRED
      remarks << "COM*** TKT DSGN " + @order.commission_designator if @order.commission_designator.present?
      ## TOUR CODE IF REQUIRED
      remarks << "COM*** FT " + @order.commission_tour_code if @order.commission_tour_code.present?
      ## ENDORSEMENT IF ANY END IS REQUIRED (пока ни разу не понадобился)
      # RM COM*** END ...

      # для некомиссионных билетов( agent_commission.zero? ):

      ## "Здесь подставляю размер сервисного сбора в зависимости от кол-ва пассажиров"
      # amadeus.cmd("RM COM*** CLAIM 0.00P")
      # amadeus.cmd("RM COM*** AGENT COM 0.00P")
      ## что такое @SF? какое-то форматирование?
      # amadeus.cmd("RM*MS98S*VCprocfe*TT11*TF<?SERV FEE AMOUNT@SF>*CM0*FPCHECK*pi")

      amadeus.pnr_add_multi_elements(
        received_from: true,
        remarks: remarks,
        pnr_action: :ER
      ).or_fail!

      # отправить в очередь на выписку
      # вроде бы как, это закрывает текущий PNR
      # TODO заменить вызовом queue_place_pnr --->
      # amadeus.queue_place_pnr(:office_id => 'NYC1S211F', :queue => '28', :category => '30', :number => @order.pnr_number)
      # ^можно вызывать в "чистой" сессии
      amadeus.cmd('QE/NYC1S211F/28C30')
    end
  end

  private

  # кодирует комиссии в формат ремарок для тикетирующего робота downtown-а
  def encode_downtown_commission(commission)
    if commission.percentage? && !commission.zero?
      "#{commission.rate}P"
    # if commission.usd?
    #   "#{commission.rate}A"
    else
      raise "ticketing in downtown with commission '#{commission}' isn't supported yet"
    end
  end

end

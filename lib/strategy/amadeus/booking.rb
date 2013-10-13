# encoding: utf-8
module Strategy::Amadeus::Booking

  def create_booking
    ::Amadeus.booking do |amadeus|
      # FIXME могут ли остаться частичные резервирования сегментов, если одно из них не прошло?
      # может быть, при ошибке канселить бронирование на всякий случай?
      # лучше сделать IG
      unless amadeus.air_sell_from_recommendation(
            :segments => @rec.journey.segments,
            :seat_total => @order_form.seat_total,
            :recommendation => @rec
          ).segments_confirmed?

        logger.error 'Strategy::Amadeus: segments aren\'t confirmed in create_booking method'
        return :failed
      end
      # FIXME если отваливается здесь по таймауту, то мы не узнаем номер брони и не запишем в базу.
      # А она может быть сохраненная и с местами.
      add_multi_elements = amadeus.pnr_add_multi_elements(@order_form)
      unless add_multi_elements.success?
        if add_multi_elements.pnr_number
          logger.error "Strategy::Amadeus: номер брони есть, но возникла какая-то ошибка"
          amadeus.pnr_cancel
        else
          logger.error "Strategy::Amadeus: Не получили номер брони"
          amadeus.pnr_ignore
          if add_multi_elements.name_errors.present? || add_multi_elements.srfoid_errors.present?
            add_multi_elements.or_fail!
          end
        end
        return :failed
      end
      unless @order_form.pnr_number = add_multi_elements.pnr_number
        # при сохранении случилась какая-то ошибка, номер брони не выдан.
        logger.error "Strategy::Amadeus: Не получили номер брони"
        amadeus.pnr_ignore
        return :failed
      end
      logger.info "Strategy::Amadeus: processing booking: #{add_multi_elements.pnr_number}"
      @order_form.save_to_order

      # важно для дальнейшего cancel
      @order = @order_form.order
      @order.save_stored_flights(@rec.flights)

      # Выставляем флаг автовыписки
      auto_ticket_stuff = AutoTicketStuff.new(order: @order, people: @order_form.people, recommendation: @order_form.recommendation)
      if auto_ticket_stuff.auto_ticket
        @order.update_attributes(auto_ticket: true)
        auto_ticket_stuff.create_auto_ticket_job
      else
        @order.update_attributes(no_auto_ticket_reason: auto_ticket_stuff.turndown_reason)
      end

      set_people_numbers(add_multi_elements.passengers)

      # надо попытаться сохранить эти сообщения в заказе
      # может сохранить при:
      # неправильно выставленном таймлимите
      # недостаточном времени стыковки
      # (не страшно, но) наземный участок
      amadeus.pnr_commit_really_hard do
        pricing = amadeus.fare_price_pnr_with_booking_class(:validating_carrier => @rec.validating_carrier.iata).or_fail!
        @rec.last_tkt_date = pricing.last_tkt_date
        # FIXME отреагировать на изменение цены/продаваемости
        new_rec = @rec.dup_with_new_prices(pricing.prices)
        unless @order_form.price_with_payment_commission == new_rec.price_with_payment_commission
          logger.error "Strategy::Amadeus: Изменилась цена при тарифицировании: #{@order_form.price_with_payment_commission} -> #{new_rec.price_with_payment_commission}"
          # не попытается ли сохранить бронь после выхода из блока?
          amadeus.pnr_cancel
          @order_form.price_with_payment_commission = new_rec.price_with_payment_commission
          @order_form.recommendation = new_rec
          @order_form.update_in_cache
          return :price_changed
        end

        if !lax && !TimeChecker.ok_to_sell(@rec.journey.departure_datetime_utc, @rec.last_tkt_date)
          logger.error "Strategy: time criteria for last tkt date missed: #{@rec.last_tkt_date}"
          dropped_recommendations_logger.info "recommendation: #{@rec.serialize} price_total: #{@rec.price_total} #{Time.now.strftime("%H:%M %d.%m.%Y")}"
          amadeus.pnr_cancel
          return :failed
        end

        # FIXME среагировать на отсутствие маски
        amadeus.ticket_create_tst_from_pricing(:fares_count => pricing.fares_count).or_fail!

#        amadeus.pnr_transfer_ownership(:number => @order_form.pnr_number, :office_id => ::Amadeus::Session::TICKETING)
      end.or_fail!

      # повторяем в случае прихода ремарок
      amadeus.pnr_commit_really_hard do
        amadeus.cmd("rp/#{::Amadeus::Session::TICKETING}/all")
      end.or_fail!

      #amadeus.queue_place_pnr(:number => @order_form.pnr_number)
      # FIXME вынести в контроллер
      @order_form.save_to_order

      #Еще раз проверяем, что все сегменты доступны
      # вообще говоря, pnr_really_hard тоже получает эти данные. сэкономить транзакцию?
      unless amadeus.pnr_retrieve(:number => @order_form.pnr_number).all_segments_available?
        logger.error "Strategy::Amadeus: Не подтверждены места"
        cancel
        return :failed
      end

      # если не было cancel можно посылать нотификацию
      @order.email_ready!

      # обилечивание
      #Amadeus::Service.issue_ticket(@order_form.pnr_number)

      # Пишем в лог время, за которое пользователь заполнил форму
      order_form_created_at = OrderFormCache.find(@order_form.number).created_at
      logger.info "User filled out a form in #{((Time.now - order_form_created_at)/60.0).ceil} minutes"

      # success!!
      return :success
    end
  end


  private

  # FIXME наверное испортится, если совпадают имена у двух пассажиров, или если будем делать транслитерацию
  def set_people_numbers(returned_people)
    returned_people.each do |p|
      @order_form.people.detect do |person|
        person.last_name.upcase == p.last_name && (person.first_name_with_code).upcase == p.first_name
      end.number_in_amadeus = p.number_in_amadeus
    end
  end

end

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
        return
      end
      add_multi_elements = amadeus.pnr_add_multi_elements(@order_form)
      unless add_multi_elements.success?
        if add_multi_elements.pnr_number
          logger.error "Strategy::Amadeus: номер брони есть, но возникла какая-то ошибка"
          amadeus.pnr_cancel
        else
          logger.error "Strategy::Amadeus: Не получили номер брони"
          amadeus.pnr_ignore
        end
        return
      end
      unless @order_form.pnr_number = add_multi_elements.pnr_number
        # при сохранении случилась какая-то ошибка, номер брони не выдан.
        logger.error "Strategy::Amadeus: Не получили номер брони"
        amadeus.pnr_ignore
        return
      end
      logger.info "Strategy::Amadeus: processing booking: #{add_multi_elements.pnr_number}"
      @order_form.save_to_order

      set_people_numbers(add_multi_elements.passengers)

      # надо попытаться сохранить эти сообщения в заказе
      # может сохранить при:
      # неправильно выставленном таймлимите
      # недостаточном времени стыковки
      # (не страшно, но) наземный участок
      amadeus.pnr_commit_really_hard do
        pricing = amadeus.fare_price_pnr_with_booking_class(:validating_carrier => @rec.validating_carrier.iata).or_fail!
        @rec.last_tkt_date = pricing.last_tkt_date
        unless [@rec.price_fare, @rec.price_tax] == pricing.prices
          logger.error "Strategy::Amadeus: Изменилась цена при тарифицировании: #{@rec.price_fare}, #{@rec.price_tax} -> #{pricing.prices}"
          # не попытается ли сохранить бронь после выхода из блока?
          amadeus.pnr_cancel
          return
        end

        unless TimeChecker.ok_to_sell(@rec.journey.departure_datetime_utc, @rec.last_tkt_date)
          logger.error "Strategy: time criteria for last tkt date missed: #{@rec.last_tkt_date}"
          dropped_recommendations_logger.info "recommendation: #{@rec.serialize} price_total: #{@rec.price_total} #{Time.now.strftime("%H:%M %d.%m.%Y")}"
          amadeus.pnr_cancel
          return
        end

        # FIXME среагировать на отсутствие маски
        amadeus.ticket_create_tst_from_pricing(:fares_count => pricing.fares_count).or_fail!
      end

      # повторяем в случае прихода ремарок
      amadeus.pnr_commit_really_hard do
        add_passport_data(amadeus)
        # делается автоматически, настройками booking office_id
        #amadeus.give_permission_to_offices(
        #  Amadeus::Session::TICKETING,
        #  Amadeus::Session::WORKING
        #)
        #Передача прав из одного офиса в другой
        #FIXME надо как-то согласовать с предыдущей частью
        amadeus.cmd("es#{::Amadeus::Session::BOOKING}-B")
        amadeus.cmd("rp/#{::Amadeus::Session::WORKING}/all")
        # FIXME надо ли архивировать в самом конце?
        amadeus.pnr_archive(@order_form.seat_total)
        # FIXME перенести ремарку поближе к началу.
        amadeus.pnr_add_remark
      end



      #amadeus.queue_place_pnr(:number => @order_form.pnr_number)
      # FIXME вынести в контроллер
      @order_form.save_to_order
      # важно для дальнейшего cancel
      @order = @order_form.order

      #Еще раз проверяем, что все сегменты доступны
      # вообще говоря, pnr_really_hard тоже получает эти данные. сэкономить транзакцию?
      unless amadeus.pnr_retrieve(:number => @order_form.pnr_number).all_segments_available?
        logger.error "Strategy::Amadeus: Не подтверждены места"
        cancel
        return
      end

      # если не было cancel можно посылать нотификацию
      @order.email_ready!

      # обилечивание
      #Amadeus::Service.issue_ticket(@order_form.pnr_number)

      # success!!
      return @order_form.pnr_number
    end
  end


  private

  # FIXME нужна же какая-то обработка ошибок?
  def add_passport_data(amadeus)
    validating_carrier_code = @rec.validating_carrier.iata
    (@order_form.adults + @order_form.children).each do |person|
      # YY = для всех перевозчиков в бронировании
      amadeus.cmd( "SRDOCSYYHK1-P-#{person.nationality.alpha3}-#{person.cleared_passport}-#{person.nationality.alpha3}-#{person.birthday.strftime('%d%b%y').upcase}-#{person.sex.upcase}-#{person.smart_document_expiration_date.strftime('%d%b%y').upcase}-#{person.last_name}-#{person.first_name}-H/P#{person.number_in_amadeus}")
      amadeus.cmd("SR FOID #{validating_carrier_code} HK1-PP#{person.cleared_passport}/P#{person.number_in_amadeus}")
      amadeus.cmd("FE #{validating_carrier_code} ONLY PSPT #{person.cleared_passport}/P#{person.number_in_amadeus}")
      amadeus.cmd("FFN#{person.bonuscard_type}-#{person.bonuscard_number}/P#{person.number_in_amadeus}") if person.bonus_present
    end
    @order_form.infants.each_with_index do |person, i|
      # YY = для всех перевозчиков в бронировании
      amadeus.cmd( "SRDOCSYYHK1-P-#{person.nationality.alpha3}-#{person.cleared_passport}-#{person.nationality.alpha3}-#{person.birthday.strftime('%d%b%y').upcase}-#{person.sex.upcase}I-#{person.smart_document_expiration_date.strftime('%d%b%y').upcase}-#{person.last_name}-#{person.first_name}-H/P#{person.number_in_amadeus}")
      amadeus.cmd("FE INF #{validating_carrier_code} ONLY PSPT #{person.cleared_passport}/P#{person.number_in_amadeus}")
    end
    amadeus.cmd('OSYYCTCP74956603520 EVITERRA TRAVEL-A')
    amadeus.cmd("OSYYCTCP#{@order_form.phone.gsub(/\D/, '' )}-M")
  end

  # FIXME наверное испортится, если совпадают имена у двух пассажиров, или если будем делать транслитерацию
  def set_people_numbers(returned_people)
    returned_people.each do |p|
      @order_form.people.detect do |person|
        person.last_name.upcase == p.last_name && (person.first_name_with_code).upcase == p.first_name
      end.number_in_amadeus = p.number_in_amadeus
    end
  end

end

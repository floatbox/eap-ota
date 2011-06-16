# encoding: utf-8
# TODO изменить имя на что-то менее generic
class Strategy

  include KeyValueInit

  attr_accessor :rec, :search

  cattr_accessor :dropped_recommendations_logger do
    ActiveSupport::BufferedLogger.new(Rails.root + 'log/dropped_recommendations.log')
  end

  cattr_accessor :logger do
    Rails.logger
  end

  attr_writer :source
  def source
    @source || @rec.source
  end

  # preliminary booking
  # ###################

  def check_price_and_availability
    unless TimeChecker.ok_to_sell(@search.form_segments[0].date_as_date)
      logger.error 'Strategy: time criteria missed'
      return
    end

    case source

    when 'amadeus'
      unless hahn_air_allows?(@rec)
        logger.error 'Strategy: forbidden by Hahn Air'
        return
      end
      Amadeus.booking do |amadeus|
        @rec.price_fare, @rec.price_tax =
          amadeus.fare_informative_pricing_without_pnr(
            :recommendation => @rec,
            :flights => @rec.flights,
            :people_count => @search.real_people_count,
            :validating_carrier => @rec.validating_carrier_iata
          ).prices

        # FIXME не очень надежный признак
        if @rec.price_fare.to_i == 0
          logger.error 'Strategy: price_fare is 0?'
        end

        @rec.rules = amadeus.fare_check_rules.rules

        # FIXME точно здесь нельзя нечаянно заморозить места?
        air_sfr = amadeus.air_sell_from_recommendation(
          :recommendation => @rec,
          :segments => @rec.segments,
          :seat_total => @search.seat_total
        )
        @rec.last_tkt_date = amadeus.fare_price_pnr_with_booking_class(:validating_carrier => @rec.validating_carrier.iata).last_tkt_date
        amadeus.pnr_ignore
        unless air_sfr.segments_confirmed?
          logger.error 'Strategy: segments aren\'t confirmed'
          return
        end
        unless TimeChecker.ok_to_sell(@rec.variants[0].flights[0].dept_date, @rec.last_tkt_date)
          logger.error 'Strategy: time criteria for last tkt date missed'
          dropped_recommendations_logger.info "recommendation: #{@rec.serialize} price_total: #{@rec.price_total} #{Time.now.strftime("%H:%M %d.%m.%Y")}"
          return
        end
        air_sfr.fill_itinerary!(@rec.segments)
        @rec
      end

    when 'sirena'
      # FIXME может быть, просто вернуть новую рекомендацию?
      sirena = Sirena::Service.new
      unless repriced_rec = sirena.pricing(@search, :recommendation => @rec).recommendation
        logger.info 'Strategy: got no recommendation'
        return
      end
      # FIXME действительно может отличаться от результата проверки выше?
      unless TimeChecker.ok_to_sell(repriced_rec.variants[0].flights[0].dept_date)
        logger.error 'Strategy: missed time criteria, again'
        return
      end
      @rec.rules = sirena_rules(repriced_rec)
      @rec.price_fare = repriced_rec.price_fare
      @rec.price_tax = repriced_rec.price_tax
      # обновим количество бланков, на всякий случай
      @rec.sirena_blank_count = repriced_rec.sirena_blank_count
      @rec

    end
  end

  def hahn_air_allows? rec
    rec.validating_carrier_iata != 'HR' ||
      HahnAir.allows?(rec.marketing_carrier_iatas | rec.operating_carrier_iatas)
  end
  private :hahn_air_allows?

  def sirena_rules rec
    rec.upts.each_with_object({}) do |u, result|
      unless result[[rec.validating_carrier_iata, u[:fare_base]]]
        sirena = Sirena::Service.new
        resp = sirena.fareremark(:carrier => rec.validating_carrier_iata, :upt => u[:upt], :upt_code => u[:code])
        result[[rec.validating_carrier_iata, u[:fare_base]]] = resp.text
      end
    end
  end
  private :sirena_rules


  # booking
  # #######

  attr_accessor :order_form

  def create_booking
    case source

    when 'amadeus'
      Amadeus.booking do |amadeus|
        # FIXME могут ли остаться частичные резервирования сегментов, если одно из них не прошло?
        # может быть, при ошибке канселить бронирование на всякий случай?
        amadeus.air_sell_from_recommendation(
          :segments => @rec.variants[0].segments,
          :seat_total => @order_form.seat_total,
          :recommendation => @rec
        ).or_fail!

        add_multi_elements = amadeus.pnr_add_multi_elements(@order_form).or_fail!
        if @order_form.pnr_number = add_multi_elements.pnr_number
          set_people_numbers(add_multi_elements.passengers)

          amadeus.pnr_commit_really_hard do
            pricing = amadeus.fare_price_pnr_with_booking_class(:validating_carrier => @rec.validating_carrier.iata).or_fail!
            @order_form.last_tkt_date = pricing.last_tkt_date
            unless [@rec.price_fare, @rec.price_tax] == pricing.prices
              @order_form.errors.add :pnr_number, 'Ошибка при создании PNR'
              amadeus.pnr_cancel
              return
            end
            # FIXME среагировать на отсутствие маски
            amadeus.ticket_create_tst_from_pricing(:fares_count => pricing.fares_count).or_fail!
          end

          amadeus.pnr_commit_really_hard do
            add_passport_data(amadeus)
            # делается автоматически, настройками booking office_id
            #amadeus.give_permission_to_offices(
            #  Amadeus::Session::TICKETING,
            #  Amadeus::Session::WORKING
            #)
            # FIXME надо ли архивировать в самом конце?
            amadeus.pnr_archive(@order_form.seat_total)
            # FIXME перенести ремарку поближе к началу.
            amadeus.pnr_add_remark
          end

          #amadeus.queue_place_pnr(:number => @order_form.pnr_number)
          # FIXME вынести в контроллер
          @order_form.save_to_order

          #Еще раз проверяем, что все сегменты доступны
          if amadeus.pnr_retrieve(:number => @order_form.pnr_number).all_segments_available?

            # обилечивание
            #Amadeus::Service.issue_ticket(@order_form.pnr_number)

            return @order_form.pnr_number
          else
            @order_form.order.cancel!
            @order_form.errors.add :pnr_number, 'Ошибка при создании PNR'
            return
          end
        else
          # при сохранении случилась какая-то ошибка, номер брони не выдан.
          amadeus.pnr_ignore
          @order_form.errors.add :pnr_number, 'Ошибка при создании PNR'
          return
        end
      end

    when 'sirena'
      sirena = Sirena::Service.new
      response = sirena.booking(@order_form)
      if response.success? && response.pnr_number
        if @rec.price_fare != response.price_fare ||
           @rec.price_tax != response.price_tax
          @order_form.errors.add :pnr_number, 'Изменилась цена предложения при бронировании'
          sirena.booking_cancel(response.pnr_number, response.lead_family)
        else
          # FIXME просто проверяем возможность добавления
          # sirena.add_remark(response.pnr_number, response.lead_family, '')
          payment_query = sirena.payment_ext_auth(:query, response.pnr_number, response.lead_family)
          if payment_query.success? && payment_query.cost
            if payment_query.cost == @rec.price_fare + @rec.price_tax
              @order_form.pnr_number = response.pnr_number
              @order_form.sirena_lead_pass = response.lead_family
              @order_form.save_to_order
            else
              @order_form.errors.add :pnr_number, 'Изменилась цена после тарификации'
              sirena.payment_ext_auth(:cancel, response.pnr_number, response.lead_family)
              sirena.booking_cancel(response.pnr_number, response.lead_family)
            end
          else
            @order_form.errors.add :pnr_number,  payment_query.error || 'Ошибка при тарицифировании PNR'
            sirena.booking_cancel(response.pnr_number, response.lead_family)
          end
        end
      else
        @order_form.errors.add :pnr_number, response.error || 'Ошибка при бронировании'
      end
      @order_form.pnr_number
    end
  end

  # for amadeus
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
  end
  private :add_passport_data

  # for amadeus
  # FIXME наверное испортится, если совпадают имена у двух пассажиров, или если будем делать транслитерацию
  def set_people_numbers(returned_people)
    returned_people.each do |p|
      @order_form.people.detect do |person|
        person.last_name.upcase == p.last_name && (person.first_name_with_code).upcase == p.first_name
      end.number_in_amadeus = p.number_in_amadeus
    end
  end
  private :set_people_numbers


  # ticketing
  # #########

  def delayed_ticketing?
    case source
    when 'amadeus'
      true
    when 'sirena'
      false
    end
  end

  def ticket(order)
    sirena = Sirena::Service.new
    payment_confirm = sirena.payment_ext_auth(:confirm, order.pnr_number, order.sirena_lead_pass,
                                      :cost => (order.price_fare + order.price_tax))
    if payment_confirm.success?
      order.ticket!
      return true
    else
      #FIXME Отменять в случае exception
      # FIXME Order#cancel! делает то же самое.
      # sirena.payment_ext_auth(:cancel, order.pnr_number, order.sirena_lead_pass)
      # we can't simply cancel order if it is in query
      order.cancel!
      return false
    end
  end
end


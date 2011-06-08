# encoding: utf-8
# TODO изменить имя на что-то менее generic
class Strategy

  include KeyValueInit

  attr_accessor :rec, :search

  cattr_accessor :dropped_recommendations_logger do
    ActiveSupport::BufferedLogger.new(Rails.root + 'log/dropped_recommendations.log')
  end

  # preliminary booking
  # ###################

  def check_price_and_availability
    case rec.source

    when 'amadeus'
      return unless hahn_air_allows?(rec)
      Amadeus.booking do |amadeus|
        rec.price_fare, rec.price_tax =
          amadeus.fare_informative_pricing_without_pnr(
            :recommendation => rec,
            :flights => rec.flights,
            :people_count => search.real_people_count,
            :validating_carrier => rec.validating_carrier_iata
          ).prices

        # FIXME не очень надежный признак
        return if rec.price_fare.to_i == 0
        rec.rules = amadeus.fare_check_rules.rules
        air_sfr = amadeus.air_sell_from_recommendation(
          :recommendation => rec,
          :segments => rec.segments,
          :seat_total => search.seat_total
        )
        rec.last_tkt_date = amadeus.fare_price_pnr_with_booking_class(:validating_carrier => rec.validating_carrier.iata).last_tkt_date
        amadeus.pnr_ignore
        return unless air_sfr.segments_confirmed?
        return unless TimeChecker.ok_to_sell(rec.variants[0].flights[0].dept_date, rec.last_tkt_date)
        unless TimeChecker.ok_to_sell(rec.variants[0].flights[0].dept_date, rec.last_tkt_date)
          dropped_recommendations_logger.info "recommendation: #{rec.serialize} price_total: #{rec.price_total} #{Time.now.strftime("%H:%M %d.%m.%Y")}"
          return
        end
        air_sfr.fill_itinerary!(rec.segments)
        rec
      end

    when 'sirena'
      # FIXME может быть, просто вернуть новую рекомендацию?
      recs = Sirena::Service.pricing(search, rec).recommendations
      # вынести в Sirena::Response::Pricing
      repriced_rec = recs && recs[0]
      rec.rules = sirena_rules(repriced_rec)
      return unless TimeChecker.ok_to_sell(repriced_rec.variants[0].flights[0].dept_date)
      if repriced_rec
        rec.price_fare = repriced_rec.price_fare
        rec.price_tax = repriced_rec.price_tax
        # обновим количество бланков, на всякий случай
        rec.sirena_blank_count = repriced_rec.sirena_blank_count
        rec
      end

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
        resp = Sirena::Service.fareremark(:carrier => rec.validating_carrier_iata, :upt => u[:upt], :upt_code => u[:code])
        result[[rec.validating_carrier_iata, u[:fare_base]]] = resp.text
      end
    end
  end
  private :sirena_rules


  # booking
  # #######

  attr_accessor :order_data

  def create_booking
    case rec.source

    when 'amadeus'
      Amadeus.booking do |amadeus|
        # FIXME могут ли остаться частичные резервирования сегментов, если одно из них не прошло?
        # может быть, при ошибке канселить бронирование на всякий случай?
        amadeus.air_sell_from_recommendation(
          :segments => rec.variants[0].segments,
          :seat_total => order_data.seat_total,
          :recommendation => rec
        ).or_fail!

        add_multi_elements = amadeus.pnr_add_multi_elements(order_data).or_fail!
        if order_data.pnr_number = add_multi_elements.pnr_number
          set_people_numbers(add_multi_elements.passengers)

          amadeus.pnr_commit_really_hard do
            pricing = amadeus.fare_price_pnr_with_booking_class(:validating_carrier => rec.validating_carrier).or_fail!
            order_data.last_tkt_date = pricing.last_tkt_date
            unless [rec.price_fare, rec.price_tax] == pricing.prices
              order_data.errors.add :pnr_number, 'Ошибка при создании PNR'
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
            amadeus.pnr_archive(seat_total)
            # FIXME перенести ремарку поближе к началу.
            amadeus.pnr_add_remark
          end

          #amadeus.queue_place_pnr(:number => order_data.pnr_number)
          # FIXME вынести в контроллер
          order_data.order = Order.create(:order_data => order_data)

          # обилечивание
          #Amadeus::Service.issue_ticket(order_data.pnr_number)

          return order_data.pnr_number
        else
          # при сохранении случилась какая-то ошибка, номер брони не выдан.
          amadeus.pnr_ignore
          order_data.errors.add :pnr_number, 'Ошибка при создании PNR'
          return
        end
      end

    when 'sirena'
      Sirena::Adapter.book_for_data(order_data)
    end
  end

  # for amadeus
  # FIXME нужна же какая-то обработка ошибок?
  def add_passport_data(amadeus)
    validating_carrier_code = rec.validating_carrier.iata
    (order_data.adults + order_data.children).each do |person|
      # YY = для всех перевозчиков в бронировании
      amadeus.cmd( "SRDOCSYYHK1-P-#{person.nationality.alpha3}-#{person.cleared_passport}-#{person.nationality.alpha3}-#{person.birthday.strftime('%d%b%y').upcase}-#{person.sex.upcase}-#{person.smart_document_expiration_date.strftime('%d%b%y').upcase}-#{person.last_name}-#{person.first_name}-H/P#{person.number_in_amadeus}")
      amadeus.cmd("SR FOID #{validating_carrier_code} HK1-PP#{person.cleared_passport}/P#{person.number_in_amadeus}")
      amadeus.cmd("FE #{validating_carrier_code} ONLY PSPT #{person.cleared_passport}/P#{person.number_in_amadeus}")
      amadeus.cmd("FFN#{person.bonuscard_type}-#{person.bonuscard_number}/P#{person.number_in_amadeus}") if person.bonus_present
    end
    order_data.infants.each_with_index do |person, i|
      # YY = для всех перевозчиков в бронировании
      amadeus.cmd( "SRDOCSYYHK1-P-#{person.nationality.alpha3}-#{person.cleared_passport}-#{person.nationality.alpha3}-#{person.birthday.strftime('%d%b%y').upcase}-#{person.sex.upcase}I-#{person.smart_document_expiration_date.strftime('%d%b%y').upcase}-#{person.last_name}-#{person.first_name}-H/P#{person.number_in_amadeus}")
      amadeus.cmd("FE INF #{validating_carrier_code} ONLY PSPT #{person.cleared_passport}/P#{person.number_in_amadeus}")
    end
  end
  private :add_passport_data

  # for amadeus
  def set_people_numbers(returned_people)
    returned_people.each do |p|
      order_data.people.detect do |person|
        person.last_name.upcase == p.last_name && (person.first_name_with_code).upcase == p.first_name
      end.number_in_amadeus = p.number_in_amadeus
    end
  end
  private :add_passport_data

end

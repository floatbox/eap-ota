# encoding: utf-8
module Strategy::Amadeus::PreliminaryBooking

  def check_price_and_availability
    unless TimeChecker.ok_to_book(@search.segments[0].date_as_date + 1.day)
      logger.error 'Strategy: time criteria missed'
      return
    end

    unless hahn_air_allows?(@rec)
      logger.error 'Strategy: forbidden by Hahn Air'
      return
    end
    ::Amadeus.booking do |amadeus|
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
        return
      end

      # считаем что в амадеусе всегда один билет на человека
      @rec.blank_count = @search.people_total

      @rec.rules = amadeus.fare_check_rules.rules

      # FIXME точно здесь нельзя нечаянно заморозить места?
      air_sfr = amadeus.air_sell_from_recommendation(
        :recommendation => @rec,
        :segments => @rec.segments,
        :seat_total => @search.seat_total
      )
      unless air_sfr.segments_confirmed?
        logger.error "Strategy: segments aren't confirmed: recommendation: #{@rec.serialize} segments: #{air_sfr.segments_status_codes.join(', ')} #{Time.now.strftime('%H:%M %d.%m.%Y')}"
        return
      end
      air_sfr.fill_itinerary!(@rec.segments)
      #FIXME не плохо бы здесь получать и цены (вместо первого informative_pricing_without_pnr)
      @rec.last_tkt_date = amadeus.fare_price_pnr_with_booking_class(:validating_carrier => @rec.validating_carrier.iata).last_tkt_date

      # не нужно, booking {...} убьет бронирование
      # amadeus.pnr_ignore

      unless TimeChecker.ok_to_book(@rec.variants[0].departure_datetime_utc, @rec.last_tkt_date)
        logger.error "Strategy: time criteria for last tkt date missed: #{@rec.last_tkt_date}"
        dropped_recommendations_logger.info "recommendation: #{@rec.serialize} price_total: #{@rec.price_total} #{Time.now.strftime("%H:%M %d.%m.%Y")}"
        return
      end
      @rec
    end
  end


  private

  def hahn_air_allows? rec
    rec.validating_carrier_iata != 'HR' ||
      HahnAir.allows?(rec.marketing_carrier_iatas | rec.operating_carrier_iatas)
  end

end

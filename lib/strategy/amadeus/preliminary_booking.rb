# encoding: utf-8
module Strategy::Amadeus::PreliminaryBooking
  CABINS_MAPPING = {'M' => 'E', 'W' => 'E', 'Y' => 'E', 'C' => 'B', 'F' => 'F'}

  def check_price_and_availability(forbid_class_changing = Conf.amadeus.forbid_class_changing)
    @forbid_class_changing = forbid_class_changing
    if !lax && !TimeChecker.ok_to_book(@rec.dept_date + 1.day)
      logger.error 'Strategy::Amadeus::Check: time criteria missed'
      return
    end

    unless hahn_air_allows?(@rec)
      logger.error 'Strategy::Amadeus::Check: forbidden by Hahn Air'
      return
    end
    # считаем что в амадеусе всегда один билет на человека
    @rec.blank_count = @search.people_total

    ::Amadeus.booking do |amadeus|
      return if !get_places_and_last_tkt_date(amadeus) || !get_price_and_rules(amadeus)
      # не нужно, booking {...} убьет бронирование
      # amadeus.pnr_ignore

    end
    if !lax && !TimeChecker.ok_to_book(@rec.journey.departure_datetime_utc, @rec.last_tkt_date)
      logger.error "Strategy::Amadeus::Check: time criteria for last tkt date missed: #{@rec.last_tkt_date}"
      dropped_recommendations_logger.info "recommendation: #{@rec.serialize} price_total: #{@rec.price_total} #{Time.now.strftime("%H:%M %d.%m.%Y")}"
      return
    end
    logger.info "Strategy::Amadeus::Check: Success!"
    @rec
  end


  private

  def hahn_air_allows? rec
    rec.validating_carrier_iata != 'HR' ||
      HahnAir.allows?(rec.marketing_carrier_iatas | rec.operating_carrier_iatas)
  end

  def find_new_classes(amadeus)
    return if @forbid_class_changing
    amadeus.pnr_ignore
    begin
      resp = amadeus.fare_informative_best_pricing_without_pnr(
        :recommendation => @rec,
        :people_count => @search.tariffied
      )

      if resp.success?
        #дебажный вывод цен
        logger.info "strategy::amadeus::best: best_informative_pricing updated after sale: (#{@rec.booking_classes.join(' ')}) " +
          "new prices: #{resp.recommendations.map{|rec| rec.price_fare+rec.price_tax}} (#{resp.recommendations.map{|rec| rec.booking_classes.join(' ')}.join(', ')})"
        new_rec = resp.recommendations[0]
        return if new_rec.booking_classes == @rec.booking_classes || new_rec.booking_classes.count != @rec.booking_classes.count || cabin_changed?(@rec, new_rec)
        @rec.booking_classes = new_rec.booking_classes
        @rec.cabins = new_rec.cabins
      else
        logger.error "strategy::amadeus::best: best_informative_pricing updated after sale error: #{resp.error_message}"
        return
      end
    rescue
      logger.error "strategy::amadeus::best: best_informative_pricing exception: #{$!.class}: #{$!.message}"
      return
    end
    @rec
  end


  def get_places_and_last_tkt_date(amadeus)
    1.times do
      # FIXME точно здесь нельзя нечаянно заморозить места?
      air_sfr = amadeus.air_sell_from_recommendation(
        :recommendation => @rec,
        :segments => @rec.segments,
        :seat_total => @search.seat_total
      )
      unless air_sfr.segments_confirmed?
        logger.error "Strategy::Amadeus::Check: segments aren't confirmed: recommendation: #{@rec.serialize} segments: #{air_sfr.segments_status_codes.join(', ')} #{Time.now.strftime('%H:%M %d.%m.%Y')}"
        if find_new_classes(amadeus)
          redo
        else
          return
        end
      end
      # FIXME не будет ли надежнее использовать дополнительный pnr_retrieve вместо fill_itinerary?
      air_sfr.fill_itinerary!(@rec.segments)
    end
    #FIXME не плохо бы здесь получать и цены (вместо первого informative_pricing_without_pnr)
    @rec.last_tkt_date = amadeus.fare_price_pnr_with_booking_class(:validating_carrier => @rec.validating_carrier.iata).last_tkt_date
    @rec
  end


  def get_price_and_rules(amadeus)
    info_resp = amadeus.fare_informative_pricing_without_pnr(
        :recommendation => @rec,
        :people_count => @search.tariffied
      )
    @rec.price_fare, @rec.price_tax = info_resp.prices
    @rec.baggage_array = info_resp.baggage

    @rec.rules = amadeus.fare_check_rules.rules

    # FIXME не очень надежный признак
    if @rec.price_fare.to_i == 0
      logger.error 'Strategy::Amadeus::Check: price_fare is 0?'
      return
    end
    @rec
  end

  def cabin_changed?(rec1, rec2)
    rec1.cabins.map{|c| CABINS_MAPPING[c]} != rec2.cabins.map{|c| CABINS_MAPPING[c]}
  end

end

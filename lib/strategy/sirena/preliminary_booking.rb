# encoding: utf-8
module Strategy::Sirena::PreliminaryBooking

  def check_price_and_availability
    unless TimeChecker.ok_to_book(@search.segments[0].date_as_date + 1.day)
      logger.error 'Strategy: time criteria missed'
      return
    end

    # FIXME может быть, просто вернуть новую рекомендацию?
    unless repriced_rec = sirena.pricing(@search, :recommendation => @rec).recommendation
      logger.info 'Strategy: got no recommendation'
      return
    end

    @rec.rules = sirena_rules(repriced_rec)
    @rec.price_fare = repriced_rec.price_fare
    @rec.price_tax = repriced_rec.price_tax
    @rec.journey.segments = repriced_rec.segments
    @rec.blank_count = repriced_rec.blank_count

    unless TimeChecker.ok_to_book_sirena(@rec.journey.departure_datetime_utc)
      logger.error 'Strategy: time criteria missed'
      dropped_recommendations_logger.info "recommendation: #{@rec.serialize} price_total: #{@rec.price_total} #{Time.now.strftime("%H:%M %d.%m.%Y")}"
      return
    end

    @rec
  end


  private

  def sirena_rules rec
    rec.upts.each_with_object({}) do |u, result|
      unless result[[rec.validating_carrier_iata, u[:fare_base]]]
        resp = sirena.fareremark(:carrier => rec.validating_carrier_iata, :upt => u[:upt], :upt_code => u[:code])
        result[[rec.validating_carrier_iata, u[:fare_base]]] = resp.text
      end
    end
  end

end

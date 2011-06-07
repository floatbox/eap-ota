# encoding: utf-8
# TODO изменить имя на что-то менее generic
class Strategy

  include KeyValueInit

  attr_accessor :recommendation, :search

  def rec
    recommendation
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
          Recommendation.dropped_recommendations_logger.info "recommendation: #{rec.serialize(rec.variants[0])} price_total: #{rec.price_total} #{Time.now.strftime("%H:%M %d.%m.%Y")}"
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


end

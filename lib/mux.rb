# encoding: utf-8
# мультиплексор-демультиплексор запросов.
# читается как "мэкс", если что.
class Mux

  module ClassMethods

    def pricer(form)
      # пока не мержим
      if form.sirena
        sirena_pricer(form)
      else
        amadeus_pricer(form)
      end
    end

    def calendar(form)
      return [] if form.sirena

      if form.debug
        was_fake, Amadeus.fake = Amadeus.fake, true
      end

      request = Amadeus::Request::FareMasterPricerCalendar.new(form)
      recommendations = Amadeus::Service.fare_master_pricer_calendar(request).recommendations

      Amadeus.fake = was_fake if form.debug

      recommendations
    end

    # TODO exception handling
    def amadeus_pricer(form)
      request_ws = Amadeus::Request::FareMasterPricerTravelBoardSearch.new(form)
      request_ns = Amadeus::Request::FareMasterPricerTravelBoardSearch.new(form)
      request_ns.nonstop = true

      if form.debug
        was_fake, Amadeus.fake = Amadeus.fake, true
      end

      recommendations_ws = Amadeus::Service.fare_master_pricer_travel_board_search(request_ws).recommendations
      recommendations_ns = Amadeus::Service.fare_master_pricer_travel_board_search(request_ns).recommendations

      Amadeus.fake = was_fake if form.debug

      # merge
      recommendations = Recommendation.merge(recommendations_ws, recommendations_ns)

      # cleanup
      # TODO рапортовать, если хотя бы одно предложение выброшено
      # мы вроде что-то делали, чтобы амадеус не возвращал всякие поезда
      recommendations.delete_if(&:ground?)
      # sort
      recommendations = recommendations.sort_by(&:price_total)
      # regroup
      recommendations = Recommendation.corrected(recommendations)
      recommendations
    # rescue Amadeus::Error, Handsoap::Fault => e
    end

    def sirena_pricer(form)
      Sirena::Service.pricing(form).recommendations || []
    end

  end
  extend ClassMethods

end

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
      request = Amadeus::Request::FareMasterPricerCalendar.from_pricer_form(form)
      recommendations = request.invoke.recommendations
      recommendations
    end

    # TODO exception handling
    def amadeus_pricer(form)
      request_ws = Amadeus::Request::FareMasterPricerTravelBoardSearch.from_pricer_form(form)
      request_ns = Amadeus::Request::FareMasterPricerTravelBoardSearch.from_pricer_form(form)
      request_ns.nonstop = true

      recommendations_ws = request_ws.invoke.recommendations
      recommendations_ns = request_ns.invoke.recommendations

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
    end

    def sirena_pricer(form)
      Sirena::Service.action("pricing", form) || []
    end

  end
  extend ClassMethods

end

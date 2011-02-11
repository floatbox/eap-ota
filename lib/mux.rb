# encoding: utf-8
# мультиплексор-демультиплексор запросов.
# читается как "мэкс", если что.
class Mux

  module ClassMethods

    def pricer(form, admin_user = nil)
      # пока не мержим
      if form.sirena
        sirena_pricer(form)
      else
        amadeus_pricer(form, admin_user)
      end
    end

    def calendar(form, admin_user = nil)
      return [] if form.sirena

      if form.debug
        was_fake, Amadeus.fake = Amadeus.fake, true
      end

      request = Amadeus::Request::FareMasterPricerCalendar.new(form)
      recommendations = Amadeus::Service.fare_master_pricer_calendar(request).recommendations

      Amadeus.fake = was_fake if form.debug
      recommendations = recommendations.select(&:sellable?) unless admin_user
      recommendations.delete_if(&:without_full_information?)
      recommendations.every.clear_variants
      recommendations.delete_if{|r| r.variants.blank?}

      recommendations
    end

    # TODO exception handling
    def amadeus_pricer(form, admin_user = nil)
      request_ws = Amadeus::Request::FareMasterPricerTravelBoardSearch.new(form)
      request_ns = Amadeus::Request::FareMasterPricerTravelBoardSearch.new(form)
      request_ns.nonstop = true

      if form.debug
        was_fake, Amadeus.fake = Amadeus.fake, true
      end

      # TODO можно когда-нибудь вернуться. сейчас эта штука _иногда_ одновременно пытается загрузить класс
      # Country, в разных тредах
      # a_ws = Amadeus.booking
      # a_ns = Amadeus.booking

      # t_ws = Thread.new { a_ws.fare_master_pricer_travel_board_search(request_ws) }
      # t_ns = Thread.new { a_ns.fare_master_pricer_travel_board_search(request_ns) }
      # # игнорируем ошибки, если это конечно не SOAP Error
      # recommendations_ws = t_ws.value.recommendations
      # recommendations_ns = t_ns.value.recommendations
      # a_ws.session.release
      # a_ns.session.release

      # non threaded variant
      recommendations_ws = Amadeus::Service.fare_master_pricer_travel_board_search(request_ws).recommendations
      recommendations_ns = Amadeus::Service.fare_master_pricer_travel_board_search(request_ns).recommendations

      Amadeus.fake = was_fake if form.debug

      # merge
      recommendations = Recommendation.merge(recommendations_ws, recommendations_ns)

      # cleanup
      # TODO рапортовать, если хотя бы одно предложение выброшено
      # мы вроде что-то делали, чтобы амадеус не возвращал всякие поезда
      recommendations.delete_if(&:ground?)
      recommendations.delete_if(&:without_full_information?)
      recommendations = recommendations.select(&:sellable?) unless admin_user
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

# encoding: utf-8
# мультиплексор-демультиплексор запросов.
# читается как "мэкс", если что.
class Mux

  module ClassMethods

    def pricer(form, admin_user = nil)
      # FIXME делает сортировку дважды
      (
        sirena_pricer(form) + amadeus_pricer(form, admin_user)
      ).sort_by(&:price_total)
    end

    def calendar(form, admin_user = nil)
      return [] unless Conf.amadeus.enabled && Conf.amadeus.calendar

      request = Amadeus::Request::FareMasterPricerCalendar.new(form)
      recommendations = Amadeus::Service.fare_master_pricer_calendar(request).recommendations

      recommendations = recommendations.select(&:sellable?) unless admin_user
      recommendations.delete_if(&:without_full_information?)
      recommendations.every.clear_variants
      recommendations.delete_if{|r| r.variants.blank?}

      recommendations
    end

    # TODO exception handling
    def amadeus_pricer(form, admin_user = nil)
      return [] unless Conf.amadeus.enabled
      request_ws = Amadeus::Request::FareMasterPricerTravelBoardSearch.new(form)
      request_ns = Amadeus::Request::FareMasterPricerTravelBoardSearch.new(form)
      request_ns.nonstop = true

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
      #не ловим ошибку, так как может просто не быть беспосадочных вариантов, а это exception
      recommendations_ns = if Conf.amadeus.nonstop_search
                           Amadeus::Service.fare_master_pricer_travel_board_search(request_ns).recommendations
                           else [] end

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
    rescue
      notify
      []
    end

    def sirena_pricer(form)
      return [] unless Conf.sirena.enabled
      return [] unless sirena_searchable?(form)
      recommendations = Sirena::Service.pricing(form).recommendations || []
      recommendations.delete_if(&:without_full_information?)
      recommendations
    rescue
      notify
      []
    end

    def sirena_searchable?(form)
      # временно выключаем для яндексов
      form.partner.blank? && (
        !Conf.sirena.restrict ||
        # form.adults == 1 &&
        form.children == 0 && form.infants == 0 &&
        form.form_segments.none?(&:multicity?)
      )
    end

    # report error and continue
    # yanked from rails
    # actionpack/lib/action_dispatch/middleware/show_exceptions.rb
    def notify(exception = $!)
      # до логгера, чтоб была видна вся инфа по эксепшну
      ActiveSupport::Deprecation.silence do
        # выяснить, что делает именно :silent?
        backtrace = Rails.backtrace_cleaner.clean(exception.backtrace, :silent)
        message = "\n#{exception.class} (#{exception.message}):\n"
        message << "  " << backtrace.join("\n  ")
        Rails.logger.error("#{message}\n  ...reported and continued\n")
      end
      HoptoadNotifier.notify(exception) rescue Rails.logger.error("  can't notify hoptoad #{$!.class}: #{$!.message}")
    end

  end
  extend ClassMethods

end


# encoding: utf-8
# мультиплексор-демультиплексор запросов.
# читается как "мэкс", если что.
class Mux

  module ClassMethods

    def pricer(form, admin_user=false, lite=false)
      # FIXME делает сортировку дважды
      benchmark 'Pricer, total' do
        (
          sirena_pricer(form, admin_user, lite) + amadeus_pricer(form, admin_user, lite)
        ).sort_by(&:price_total)
      end
    end

    def calendar(form, admin_user=false)
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
    def amadeus_pricer(form, admin_user=false, lite=false)
      return [] unless Conf.amadeus.enabled
      benchmark 'Pricer amadeus, total' do
        request_ws = Amadeus::Request::FareMasterPricerTravelBoardSearch.new(form, lite)
        request_ns = Amadeus::Request::FareMasterPricerTravelBoardSearch.new(form, lite)
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
        recommendations_ws = benchmark 'Pricer amadeus, with stops' do
          Amadeus::Service.fare_master_pricer_travel_board_search(request_ws).recommendations
        end
        #не ловим ошибку, так как может просто не быть беспосадочных вариантов, а это exception
        recommendations_ns = if Conf.amadeus.nonstop_search && !lite
            benchmark 'Pricer amadeus, without stops' do
              Amadeus::Service.fare_master_pricer_travel_board_search(request_ns).recommendations
            end
          else
            []
          end

        # merge
        recommendations = []
        benchmark 'Pricer amadeus, merging and cleanup' do
          recommendations = Recommendation.merge(recommendations_ws, recommendations_ns)

          # cleanup
          # TODO рапортовать, если хотя бы одно предложение выброшено
          # мы вроде что-то делали, чтобы амадеус не возвращал всякие поезда
          recommendations.delete_if(&:without_full_information?)
          recommendations.delete_if(&:ground?)
          recommendations = recommendations.select(&:sellable?) unless admin_user
          unless lite
            # sort
            recommendations = recommendations.sort_by(&:price_total)
            # regroup
            recommendations = Recommendation.corrected(recommendations)
          end
        end
        recommendations
      end
    rescue
      notify
      []
    end

    def sirena_pricer(form, admin_user=false, lite=false)
      return [] unless Conf.sirena.enabled
      return [] if lite
      return [] unless sirena_searchable?(form)
      recommendations = []
      benchmark 'Pricer sirena' do
        recommendations = Sirena::Service.pricing(form, nil, lite).recommendations || []
        recommendations.delete_if(&:without_full_information?)
      end
      recommendations
    rescue
      notify
      []
    end

    SNG_COUNTRY_CODES = ["RU", "AZ", "AM", "BY", "GE", "KZ", "KG", "LV", "LT", "MD", "TJ", "TM", "UZ", "UA", "EE"]
    def sirena_searchable?(form)
      return false if form.form_segments.size > 2
      return false if form.form_segments.any? {|fs| fs.from_as_object == fs.to_as_object}
      locations = (form.form_segments.every.from_as_object + form.form_segments.every.to_as_object).uniq

      !Conf.sirena.restrict ||
        # form.adults == 1 &&
        form.children == 0 && form.infants == 0 &&
        form.form_segments.none?(&:multicity?) &&
        locations.all?{|l| l.iata_ru != l.iata && l.iata_ru.present?} &&
        locations.any?{|l| SNG_COUNTRY_CODES.include? l.country.alpha2}
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

    include ActiveSupport::Benchmarkable

    def logger
      Rails.logger
    end

  end
  extend ClassMethods

end


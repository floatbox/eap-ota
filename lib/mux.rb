# encoding: utf-8
# мультиплексор-демультиплексор запросов.
# читается как "мэкс", если что.
class Mux

  cattr_accessor :cryptic_logger do ActiveSupport::BufferedLogger.new(Rails.root + 'log/rec_cryptic.log') end
  cattr_accessor :short_logger do ActiveSupport::BufferedLogger.new(Rails.root + 'log/rec_short.log') end
  cattr_accessor :logger do Rails.logger end

  include Monitoring::Benchmarkable

  include KeyValueInit
  attr_accessor :suggested_limit, :lite, :admin_user

  def save_to_mongo(avia_search, recommendations)
    RamblerCache.create_from_form_and_recs(avia_search, recommendations)
  end

  def pricer(avia_search)
    # FIXME делает сортировку дважды
    benchmark 'Pricer, total' do
      (
        amadeus_pricer(avia_search) + sirena_pricer(avia_search)
      ).sort_by(&:price_total)
    end
  end

  def calendar(avia_search)
    return [] unless Conf.amadeus.enabled && Conf.amadeus.calendar

    amadeus = Amadeus.booking
    recommendations = amadeus.fare_master_pricer_calendar(avia_search).recommendations
    amadeus.release

    benchmark 'commission matching' do
      recommendations.find_commission!
    end

    recommendations.select_valid! do |r|
      r.select!(&:sellable?) unless admin_user
      r.map(&:clear_variants)
    end
  rescue => e
    with_warning unless ignore_error?(e)
    RecommendationSet.new
  end

  # TODO exception handling
  def amadeus_pricer(avia_search)
    return [] unless Conf.amadeus.enabled
    benchmark 'Pricer amadeus, total' do
      session = Amadeus::Session.book(Amadeus::Session::BOOKING)
      amadeus = Amadeus::Service.new(:session => session, :driver => async_amadeus_driver)
      request_ws = {:suggested_limit => suggested_limit, :lite => lite}
      request_ns = {:suggested_limit => suggested_limit, :lite => lite, :nonstop => true}
      # non threaded variant
      recommendations_ws = benchmark 'Pricer amadeus, with stops' do
        amadeus.fare_master_pricer_travel_board_search(avia_search, request_ws).recommendations
      end
      recommendations_ns = if Conf.amadeus.nonstop_search && !lite
        benchmark 'Pricer amadeus, without stops' do
          amadeus.fare_master_pricer_travel_board_search(avia_search, request_ns).recommendations
        end
      else [] end

      amadeus.release
      amadeus_merge_and_cleanup(recommendations_ws + recommendations_ns)
    end
  rescue => e
    with_warning unless ignore_error?(e)
    RecommendationSet.new
  end

  def amadeus_merge_and_cleanup(recommendations)
    benchmark 'Pricer amadeus, merging and cleanup' do

      recommendations.uniq! unless lite

      # log amadeus recommendations
      benchmark 'log_examples' do
        log_examples(recommendations)
      end

      recommendations.select!(&:full_information?)

      benchmark 'commission matching' do
        recommendations.find_commission!
      end

      recommendations.select_valid! do |r|
        r.delete_if(&:ground?)
        r.delete_if(&:ignored_carriers)

        # TODO пометить как непродаваемые, для админов?
        r.select!(&:sellable?) unless admin_user

        # сортируем и группируем, если ищем для морды
        recommendations.sort_and_group! unless lite
        # удаляем рекоммендации на сегодня-завтра
        recommendations.each(&:clear_variants)
      end
    end
    recommendations
  end

  def amadeus_async_pricer(avia_search, &block)
    return [] unless Conf.amadeus.enabled
    request_ws = {:suggested_limit => suggested_limit, :lite => lite}
    request_ns = {:suggested_limit => suggested_limit, :lite => lite, :nonstop => true}
    reqs = (lite || !Conf.amadeus.nonstop_search) ? [request_ws] : [request_ns, request_ws]
    amadeus_driver = async_amadeus_driver
    reqs.each do |req|
      session = Amadeus::Session.book(Amadeus::Session::BOOKING)
      amadeus = Amadeus::Service.new(:session => session, :driver => amadeus_driver)
      amadeus.async_fare_master_pricer_travel_board_search(avia_search, req) do |res|
        amadeus.release
        block.call(res)
      end
    end
  end

  def sirena_pricer(avia_search)
    return [] unless Conf.sirena.enabled
    return [] if lite && !Conf.sirena.enabled_in_lite
    return [] unless sirena_searchable?(avia_search)
    recommendations = RecommendationSet.new
    benchmark 'Pricer sirena' do
      recommendations = Sirena::Service.new.pricing(avia_search, :lite => lite).recommendations || []
      sirena_cleanup(recommendations)
    end

    recommendations
  rescue
    with_warning
    RecommendationSet.new
  end

  def sirena_cleanup(recs)
    recs.select_valid! do |recs|
      recs.each(&:clear_variants)
      # временно из-за проблем с тарифами AB и LX удаляем из рекоммендации
      recs.delete_if {|r| ['AB', 'LX', 'ЮХ'].include? r.validating_carrier_iata }
    end
  end

  def sirena_async_pricer(avia_search, &block)
    return [] unless Conf.sirena.enabled
    return [] if lite && !Conf.sirena.enabled_in_lite
    return [] unless sirena_searchable?(avia_search)

    sirena = Sirena::Service.new(:driver => async_sirena_driver)
    sirena.async_pricing(avia_search, :lite => lite, &block)
  end

  def async_pricer(avia_search)
    benchmark 'Pricer, async total' do
      amadeus_recommendations = RecommendationSet.new
      sirena_recommendations = RecommendationSet.new
      amadeus_async_pricer(avia_search) do |res|
        benchmark "Amadeus::Recommendations: parsing" do
          logger.info "Mux: amadeus recs: #{res.recommendations.size}"
          amadeus_recommendations += res.recommendations
        end
      end
      sirena_async_pricer(avia_search) do |res|
        logger.info "Mux: sirena recs: #{res.recommendations.size}"
        sirena_recommendations += res.recommendations
      end

      async_perform

      recommendations = amadeus_merge_and_cleanup(amadeus_recommendations) + sirena_cleanup(sirena_recommendations)
      benchmark 'creating and saving rambler cache' do
        save_to_mongo(avia_search, recommendations) if Conf.api.store_rambler_cache && !admin_user && !avia_search.complex_route?
      end
      if lite
        recommendations
      else
        recommendations.sort_by(&:price_total)
      end

    end
  end

  def async_sirena_driver
    # Sirena::TyphoeusDriver.new( :hydra => hydra )
    Sirena::MultiCurbDriver.new( :multi => multi )
  end

  def async_amadeus_driver
    # Handsoap::TyphoeusDriver.new( :hydra => hydra )
    Handsoap::MultiCurbDriver.new( :multi => multi )
  end

  def async_perform
    # hydra.run
    multi.perform
  rescue => e
    raise unless e.message['select(): Interrupted system call']
  end

  def hydra
    @hydra ||= Typhoeus::Hydra.new
  end

  def multi
    @multi ||= Curl::Multi.new
  end

  SNG_COUNTRY_CODES = ["RU", "AZ", "AM", "BY", "GE", "KZ", "KG", "LV", "LT", "MD", "TJ", "TM", "UZ", "UA", "EE"]
  def sirena_searchable?(form)
    return false if form.segments.size > 2
    return false if form.segments.any? {|fs| fs.from == fs.to}
    locations = (form.segments.every.from + form.segments.every.to).uniq

    !Conf.sirena.restrict ||
      # form.adults == 1 &&
      # form.children == 0 && form.infants == 0 &&
      form.segments.none?(&:multicity?) &&
      locations.all?{|l| l.iata_ru != l.iata && l.iata_ru.present?} &&
      locations.any?{|l| SNG_COUNTRY_CODES.include? l.country.alpha2}
  end

  # применяем только к амадеусу, для разбора интерлайнов
  def log_examples(recommendations)
    recommendations.each do |r|
      r.variants.each do |v|
        cryptic_logger.info r.cryptic(v)
      end
      short_logger.info r.short
    end
  end

  def ignore_error?(e)
    case e
    when RuntimeError
      e.message['select(): Interrupted system call']
    when Amadeus::SoapSyntaxError, Amadeus::SoapUnknownError
      true
    else
      false
    end
  end

end


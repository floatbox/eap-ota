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

  def save_to_mongo(form, recommendations)
    RamblerCache.create_from_form_and_recs(form, recommendations)
  end

  def pricer(form)
    # FIXME делает сортировку дважды
    benchmark 'Pricer, total' do
      (
        sirena_pricer(form) + amadeus_pricer(form)
      ).sort_by(&:price_total)
    end
  end

  def calendar(form)
    return [] unless Conf.amadeus.enabled && Conf.amadeus.calendar

    amadeus = Amadeus.booking
    recommendations = amadeus.fare_master_pricer_calendar(form).recommendations
    amadeus.release

    recommendations = recommendations.reject(&:ignored_carriers)
    benchmark 'commission matching calendar' do
      recommendations.every.find_commission!
    end
    recommendations = recommendations.select(&:sellable?) unless admin_user
    recommendations.delete_if(&:without_full_information?)
    recommendations.select!(&:valid_interline?)
    recommendations.every.clear_variants
    recommendations.delete_if{|r| r.variants.blank?}

    recommendations
  end

  # TODO exception handling
  def amadeus_pricer(form)
    return [] unless Conf.amadeus.enabled
    benchmark 'Pricer amadeus, total' do
      request_ws = {:suggested_limit => suggested_limit, :lite => lite}
      request_ns = {:suggested_limit => suggested_limit, :lite => lite, :nonstop => true}
      amadeus = Amadeus.booking
      # non threaded variant
      recommendations_ws = benchmark 'Pricer amadeus, with stops' do
        amadeus.fare_master_pricer_travel_board_search(form, request_ws).recommendations
      end
      recommendations_ns = if Conf.amadeus.nonstop_search && !lite
        benchmark 'Pricer amadeus, without stops' do
          amadeus.fare_master_pricer_travel_board_search(form, request_ns).recommendations
        end
      else [] end

      amadeus.release
      amadeus_merge_and_cleanup(recommendations_ws + recommendations_ns)
    end
  rescue
    with_warning
    []
  end

  def amadeus_merge_and_cleanup(recommendations)
    benchmark 'Pricer amadeus, merging and cleanup' do

      recommendations.uniq! unless lite

      # log amadeus recommendations
      benchmark 'log_examples' do
        log_examples(recommendations)
      end

      recommendations.delete_if(&:without_full_information?)
      recommendations.delete_if(&:ground?)
      recommendations.select!(&:valid_interline?)

      recommendations = recommendations.reject(&:ignored_carriers)
      benchmark 'commission matching' do
        recommendations.every.find_commission!
      end


      recommendations = recommendations.select(&:sellable?) unless admin_user

      unless lite
        # sort
        recommendations = recommendations.sort_by(&:price_total)
        # regroup
        recommendations = Recommendation.corrected(recommendations)
      end
      # TODO пометить как непродаваемые, для админов?
      recommendations.every.clear_variants unless admin_user
      recommendations.delete_if{|r| r.variants.blank?}
      recommendations
    end
  end

  def amadeus_async_pricer(form, &block)
    return [] unless Conf.amadeus.enabled
    request_ws = {:suggested_limit => suggested_limit, :lite => lite}
    request_ns = {:suggested_limit => suggested_limit, :lite => lite, :nonstop => true}
    reqs = (lite || !Conf.amadeus.nonstop_search) ? [request_ws] : [request_ns, request_ws]
    amadeus_driver = async_amadeus_driver
    reqs.each do |req|
      session = Amadeus::Session.book(Amadeus::Session::BOOKING)
      amadeus = Amadeus::Service.new(:session => session, :driver => amadeus_driver)
      amadeus.async_fare_master_pricer_travel_board_search(form, req) do |res|
        amadeus.release
        block.call(res)
      end
    end
  end

  def sirena_pricer(form)
    return [] unless Conf.sirena.enabled
    return [] if lite && !Conf.sirena.enabled_in_lite
    return [] unless sirena_searchable?(form)
    recommendations = []
    benchmark 'Pricer sirena' do
      recommendations = Sirena::Service.new.pricing(form, :lite => lite).recommendations || []
      sirena_cleanup(recommendations)
    end

    recommendations
  rescue
    with_warning
    []
  end

  def sirena_cleanup(recs)
    recs.delete_if(&:without_full_information?)
    recs.select!(&:valid_interline?)
    # временно из-за проблем с тарифами AB и LX удаляем из рекоммендации
    recs.delete_if {|r| ['AB', 'LX', 'ЮХ'].include? r.validating_carrier_iata }
    recs.every.clear_variants
    recs.delete_if{|r| r.variants.blank?}
  end

  def sirena_async_pricer(form, &block)
    return [] unless Conf.sirena.enabled
    return [] if lite && !Conf.sirena.enabled_in_lite
    return [] unless sirena_searchable?(form)

    sirena = Sirena::Service.new(:driver => async_sirena_driver)
    sirena.async_pricing(form, :lite => lite, &block)
  end

  def async_pricer(form)
    benchmark 'Pricer, async total' do
      amadeus_recommendations = []
      sirena_recommendations = []
      amadeus_async_pricer(form) do |res|
        benchmark "Amadeus::Recommendations: parsing" do
          logger.info "Mux: amadeus recs: #{res.recommendations.size}"
          amadeus_recommendations += res.recommendations
        end
      end
      sirena_async_pricer(form) do |res|
        logger.info "Mux: sirena recs: #{res.recommendations.size}"
        sirena_recommendations += res.recommendations
      end

      async_perform

      recommendations = amadeus_merge_and_cleanup(amadeus_recommendations) + sirena_cleanup(sirena_recommendations)
      benchmark 'creating and saving rambler cache' do
        save_to_mongo(form, recommendations) if Conf.api.store_rambler_cache && !admin_user && !form.complex_route?
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

end


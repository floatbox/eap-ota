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
      amadeus_pricer(avia_search).sort_by(&:price_total)
    end
  end

  def calendar(avia_search)
    return [] unless Conf.amadeus.enabled && Conf.amadeus.calendar

    amadeus = Amadeus.booking
    recommendations = amadeus.fare_master_pricer_calendar(avia_search).recommendations
    amadeus.release

    recommendations.select_valid! do |r|
      benchmark 'commission matching' do
        r.find_commission!
      end
      r.select!(&:sellable?) unless admin_user
      r.map(&:clear_variants)
    end

    recommendations

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

  def async_pricer(avia_search)
    benchmark 'Pricer, async total' do
      amadeus_recommendations = RecommendationSet.new
      amadeus_async_pricer(avia_search) do |res|
        benchmark "Amadeus::Recommendations: parsing" do
          logger.info "Mux: amadeus recs: #{res.recommendations.size}"
          amadeus_recommendations += res.recommendations
        end
      end

      async_perform

      recommendations = amadeus_merge_and_cleanup(amadeus_recommendations)
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


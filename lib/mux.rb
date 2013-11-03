# encoding: utf-8
# мультиплексор-демультиплексор запросов.
# читается как "мэкс", если что.
class Mux

  cattr_accessor :logger do Rails.logger end

  include Monitoring::Benchmarkable

  include KeyValueInit
  attr_accessor :suggested_limit, :lite, :admin_user

  def pricer(avia_search)
    amadeus_pricer(avia_search)
  end

  def calendar(avia_search)
    return RecommendationSet.new unless Conf.amadeus.enabled && Conf.amadeus.calendar

    amadeus = Amadeus.booking
    recommendations = RecommendationSet.new(
      amadeus.fare_master_pricer_calendar(avia_search).recommendations
    )
    amadeus.release

    recommendations.process! admin_user: admin_user
    recommendations

  rescue => e
    with_warning unless ignore_error?(e)
    RecommendationSet.new
  end

  # TODO exception handling
  def amadeus_pricer(avia_search)
    return RecommendationSet.new unless Conf.amadeus.enabled
    session = Amadeus::Session.book(Amadeus.office(:booking))
    amadeus = Amadeus::Service.new(:session => session, :driver => async_amadeus_driver)
    request = {:suggested_limit => suggested_limit, :lite => lite}
    recommendations = RecommendationSet.new(
      amadeus.fare_master_pricer_travel_board_search(avia_search, request).recommendations
    )

    amadeus.release

    # log amadeus recommendations
    ActiveSupport::Notifications.instrument 'amadeus_merged.mux',
      recommendations: recommendations

    recommendations.process! lite: lite, admin_user: admin_user
    recommendations
  rescue => e
    with_warning unless ignore_error?(e)
    RecommendationSet.new
  end

  def amadeus_async_pricer(avia_search, &block)
    return RecommendationSet.new unless Conf.amadeus.enabled
    request = {:suggested_limit => suggested_limit, :lite => lite}
    reqs = [request]
    amadeus_driver = async_amadeus_driver
    reqs.each do |req|
      session = Amadeus::Session.book(Amadeus.office(:booking))
      amadeus = Amadeus::Service.new(:session => session, :driver => amadeus_driver)
      amadeus.async_fare_master_pricer_travel_board_search(avia_search, req) do |res|
        amadeus.release
        block.call(res)
      end
    end
  end

  def async_pricer(avia_search)
    recommendations = []

    amadeus_async_pricer(avia_search) do |res|
      recommendations += res.recommendations
    end
    async_perform

    recommendations = RecommendationSet.new(recommendations)

    # log amadeus recommendations
    ActiveSupport::Notifications.instrument 'amadeus_merged.mux',
      recommendations: recommendations

    recommendations.process! lite: lite, admin_user: admin_user
    recommendations
  end

  def async_amadeus_driver
    Handsoap::MultiCurbDriver.new( :multi => multi )
  end

  def async_perform
    # hydra.run
    multi.perform
  rescue => e
    raise unless ignore_error?(e)
  end

  def multi
    @multi ||= Curl::Multi.new
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


#encoding: utf-8

module Monitoring
  module Subscribers
    if Conf.riemann.enabled
      require_relative 'subscribers/benchmarking.rb' if Conf.riemann.benchmarking
      require_relative 'subscribers/request_performance.rb' if Conf.riemann.request_performance
      require_relative 'subscribers/stat_counters.rb' if Conf.riemann.stat_counters
      require_relative 'subscribers/meter.rb' if Conf.riemann.meter
    end
  end
end
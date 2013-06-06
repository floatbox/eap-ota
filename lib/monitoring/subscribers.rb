#encoding: utf-8
require_relative 'subscribers/benchmarking.rb'
require_relative 'subscribers/request_performance.rb'
require_relative 'subscribers/stat_counters.rb'

module Monitoring
  module Subscribers
    if Conf.riemann.enabled
      include Benchmarking if Conf.riemann.benchmarking
      include RequestPerformance if Conf.riemann.request_performance
      include StatCounters if Conf.riemann.stat_counters
      # TODO: перенести сюда
      #include CurlHelper if Conf.riemann.curl_helper
    end
  end
end
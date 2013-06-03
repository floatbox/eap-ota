#encoding: utf-8

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
#encoding: utf-8

module Monitoring
  module Subscribers
    if Conf.riemann.enabled
      include Benchmarking if Conf.riemann.benchmarking
      include RequestPerformance if Conf.riemann.request_performance
    end
  end
end
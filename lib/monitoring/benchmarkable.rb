# encoding: utf-8

module Monitoring
  module Benchmarkable
    def benchmark(message = "unknown_benchmark", options = {})
      result = nil
      ms = Benchmark.ms { result = yield }
      # TODO убрать gsub'ы и переименовать ключики в бенчмаркаемых блоках
      key = "benchmark.#{message.gsub(/,/, '').gsub(/\s/, '_')}"

      ActiveSupport::Notifications.instrument :benchmark,
        graph_type: 'gauge',
        value: ms,
        key: key
      result
    end

    def meter(key, value=nil)
      if block_given?
        result = yield
        return result
      else
        ActiveSupport::Notifications.instrument :meter,
          value: result = value,
          key: "meter.#{key}"
      end
      result
    end
  end
end


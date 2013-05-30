# encoding: utf-8

if Conf.riemann.enabled && Conf.riemann.benchmarking

  # бенчмаркаем контроллеры
  ActiveSupport::Notifications.subscribe /process_action.action_controller/ do |*args| 
    event = ActiveSupport::Notifications::Event.new(*args)
    controller = event.payload[:controller]
    action = event.payload[:action]
    format = event.payload[:format] || "all" 
    format = "all" if format == "*/*" 
    status = event.payload[:status]
    key_base = "request_performance.#{controller}.#{action}.#{format}"

    # Метрики которые идут в графит
    ActiveSupport::Notifications.instrument :benchmark,
      key: "#{key_base}.total_duration",
      value: event.duration,
      graph_type: 'gauge'

    ActiveSupport::Notifications.instrument :benchmark,
      key: "#{key_base}.db_time",
      value: event.payload[:db_runtime],
      graph_type: 'gauge'

    ActiveSupport::Notifications.instrument :benchmark,
      key: "#{key_base}.view_time",
      value: event.payload[:view_runtime],
      graph_type: 'gauge'

    ActiveSupport::Notifications.instrument :benchmark,
      key: "#{key_base}.status.#{status}",
      graph_type: 'meter'
  end


  ActiveSupport::Benchmarkable.module_eval do

    def benchmark(message = "unknown_benchmark", options = {})
      if logger

        options.assert_valid_keys(:level, :silence)
        options[:level] ||= :info

        result = nil
        ms = Benchmark.ms { result = options[:silence] ? silence { yield } : yield }

        # TODO убрать gsub'ы и переименовать ключики в бенчмаркаемых блоках
        key = "benchmark.#{message.gsub(/,/, '').gsub(/\s/, '_')}"

        ActiveSupport::Notifications.instrument :benchmark,
          graph_type: 'gauge',
          value: ms,
          key: key

        logger.send(options[:level], '%s (%.1fms)' % [ message, ms ])
        result
      else
        yield
      end
    end

  end

end
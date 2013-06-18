# encoding: utf-8

module Monitoring
  module Subscribers
    module RequestPerformance
      # бенчмаркаем контроллеры
      ActiveSupport::Notifications.subscribe 'process_action.action_controller' do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        controller = event.payload[:controller]
        action = event.payload[:action]
        format = event.payload[:format] || "all"
        format = "all" if format == "*/*"
        status = event.payload[:status]
        mongo_time = event.payload[:mongo_runtime]
        key_base = "request_performance.#{controller}.#{action}.#{format}"

        ## отсылка метрик в graphite
        # total
        ::Monitoring.gauge(
          service: "#{key_base}.total_duration",
          metric: event.duration
        )
        ::Monitoring.histogram(
          service: "#{key_base}.hist.total_duration",
          metric: event.duration
        )

        # db time
        ::Monitoring.gauge(
          service: "#{key_base}.db_time",
          metric: event.payload[:db_runtime]
        )
        ::Monitoring.histogram(
          service: "#{key_base}.hist.db_time",
          metric: event.payload[:db_runtime]
        )

        # mongo time
        ::Monitoring.gauge(
          service: "#{key_base}.mongo_time",
          metric: event.payload[:mongo_runtime]
        )
        ::Monitoring.histogram(
          service: "#{key_base}.hist.mongo_time",
          metric: event.payload[:mongo_runtime]
        )

        # view time
        ::Monitoring.gauge(
          service: "#{key_base}.view_time",
          metric: event.payload[:view_runtime]
        )
        ::Monitoring.histogram(
          service: "#{key_base}.hist.view_time",
          metric: event.payload[:view_runtime]
        )

        ::Monitoring.meter(service: "#{key_base}.status.#{status}")
      end
    end
  end
end


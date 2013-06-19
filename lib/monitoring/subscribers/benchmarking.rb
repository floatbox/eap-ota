# encoding: utf-8

module Monitoring
  module Subscribers
    module Benchmarking
      # рисуем графики по бенчмаркам
      ActiveSupport::Notifications.subscribe 'benchmark' do |name, start, finish, id, payload|
        graph_type = payload[:graph_type] || 'gauge'
        ::Monitoring.send(graph_type,
          service: payload[:key],
          metric: (payload[:value].to_f || 1.0 )
        )
      end
    end
  end
end

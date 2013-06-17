# encoding: utf-8

module Monitoring
  module Subscribers
    module StatCounters
      # бенчмаркаем контроллеры
      ActiveSupport::Notifications.subscribe 'stat_counter' do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)

        keys = event.payload[:keys] || []
        keys.each do |key|
          ::Monitoring.meter(
            service: "stat_counters.#{key}",
            metric: 1.0
          )
        end
      end
    end
  end
end


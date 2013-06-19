# encoding: utf-8

module Monitoring
  module Subscribers
    module Meter
      ActiveSupport::Notifications.subscribe 'meter' do |name, start, finish, id, payload|
        ::Monitoring.histogram(
          service: "#{payload[:key]}.hist.recommendations",
          metric: (payload[:value].to_f || 1.0 )
        )
        ::Monitoring.gauge(
          service: "#{payload[:key]}.recommendations",
          metric: (payload[:value].to_f || 1.0 )
        )
      end
    end
  end
end


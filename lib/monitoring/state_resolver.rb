# encoding: utf-8

module Monitoring
  class StateResolver
=begin
Состояния представляют из себя словарь вида
  metric: {
    state1: threshold1,
    state2: threshold2,
    ...
  },
при этом threshold1 < threshold2 < ... < thresholdN.
state может быть любым, но лучше использовать
ok/warning/error/critical (по возрастанию важности)
=end
    STATES = begin
      path = Rails.root.join('config', 'monitoring_states', "#{Rails.env}.yml")
      if File.exists?(path)
        YAML.load_file(path)
      else
        {}
      end
    end

    def initialize event_hash
      @service = event_hash[:service]
      @metric  = event_hash[:metric]
    end

    def state
      return 'ok' unless @service.present?
      return 'ok' unless STATES[@service].present?
      return 'ok' unless @metric.present?

      STATES[@service].take_while do |_, threshold|
        threshold < @metric
      end.last.first
    end
  end
end

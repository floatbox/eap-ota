# encoding: utf-8

module Monitoring
  class StateResolver
    STATES = begin
      path = Rails.root.join('config', 'monitoring_states', "#{Rails.env}.yml")
      if File.exists?(path)
        YAML.load_file(path)
      else
        {}
      end
    end

    DEFAULT_STATE = 'ok'.freeze

    def initialize event_hash
      @service = event_hash[:service]
      @metric  = event_hash[:metric]
    end

    def state
      return DEFAULT_STATE unless STATES[@service]
      return DEFAULT_STATE unless @metric

      STATES[@service].take_while do |_, threshold|
        threshold < @metric
      end.last.first
    end
  end
end

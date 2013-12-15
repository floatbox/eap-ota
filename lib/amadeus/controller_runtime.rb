module Amadeus
  module ControllerRuntime
    extend ActiveSupport::Concern

    protected

    attr_internal :amadeus_runtime

    def process_action action, *args
      LogSubscriber.reset_runtime
      super
    end

    def cleanup_view_runtime
      amadeus_rt_before = LogSubscriber.reset_runtime
      runtime = super
      amadeus_rt_after  = LogSubscriber.reset_runtime
      self.amadeus_runtime = amadeus_rt_before + amadeus_rt_after

      if amadeus_rt_after.to_i > 0
        runtime - amadeus_runtime
      else
        runtime
      end
    end

    def append_info_to_payload payload
      super
      payload[:amadeus_runtime] = amadeus_runtime
    end

    module ClassMethods
      def log_process_action payload
        messages, amadeus_runtime = super, payload[:amadeus_runtime]
        messages << ("Amadeus: %.1fms" % amadeus_runtime.to_f) if amadeus_runtime
        messages
      end
    end
  end
end

ActiveSupport.on_load(:action_controller) do
  include Amadeus::ControllerRuntime
end

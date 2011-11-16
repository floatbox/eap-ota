module Amadeus
  module Request
    class PNRAddMultiElements < Amadeus::Request::Base

      include CopyAttrs

      attr_accessor :people_count, :email, :phone, :people, :adults, :children, :infants, :validating_carrier, :agent_commission, :tk_xl
      def action_codes
        {:NOP => 0, :ET => 10, :ER => 11, :ETK => 12, :ERK => 13, :EF => 14, :ETX => 15, :ERX => 16, :IG => 20, :IR => 21, :STOP => 267, :WARNINGS => 30, :SHORT => 50}
      end
      attr_accessor :pnr_action
      attr_accessor :recommendation #сейчас не используется

      # может принимать PricerForm
      def initialize(opts)
        # defaults
        @pnr_action = :ER
        # end of defaults
        if opts.is_a? Hash
          super
        else
          copy_attrs opts, self,
            :people_count,
            :email,
            :phone,
            :people,
            :adults,
            :children,
            :infants,
            :validating_carrier,
            :agent_commission,
            :tk_xl
        end
      end

      def tk_xl_date
        (tk_xl).strftime("%d%m%y") if tk_xl
      end

      def tk_xl_time
        (tk_xl).strftime("%H%M") if tk_xl
      end

      def agent_commission?
        !!agent_commission
      end

      def agent_commission_percentage
        agent_commission.percentage? && ("%g" % agent_commission.rate)
      end

      def agent_commission_value
        raise "trying to add percentage or complex formula at FM? (#{agent_commission})" if
          agent_commission.complex? || agent_commission.percentage?
        # рублевая комиссия округляется до ближайшего целого
        # евро подставляются в дефолтных параметрах формулы из конфига (зря?)
        agent_commission.call.round
      end

    end
  end
end


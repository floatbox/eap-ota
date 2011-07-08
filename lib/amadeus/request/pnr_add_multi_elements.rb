module Amadeus
  module Request
    class PNRAddMultiElements < Amadeus::Request::Base

      include CopyAttrs

      attr_accessor :people_count, :email, :phone, :people, :adults, :children, :infants, :validating_carrier, :commission, :tk_xl
      def action_codes
        {:NOP => 0, :ET => 10, :ER => 11, :ETK => 12, :ERK => 13, :EF => 14, :ETX => 15, :ERX => 16, :IG => 20, :IR => 21, :STOP => 267, :WARNINGS => 30, :SHORT => 50}
      end
      attr_accessor_with_default :pnr_action, :ER
      attr_accessor :recommendation #сейчас не используется

      # может принимать PricerForm
      def initialize(opts)
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
            :commission,
            :tk_xl
        end
      end

      def tk_xl_date
        (tk_xl).strftime("%d%m%y") if tk_xl
      end

      def tk_xl_time
        (tk_xl).strftime("%H%M") if tk_xl
      end

      def commission?
        !!commission
      end

      def commission_percentage
        commission.agent_percentage? && ("%g" % commission.agent_value)
      end

      def commission_value
        # рублевая комиссия округляется до ближайшего целого
        commission.agent_value.round
      end

    end
  end
end


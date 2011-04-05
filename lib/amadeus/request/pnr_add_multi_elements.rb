module Amadeus
  module Request
    class PNRAddMultiElements < Amadeus::Request::Base
      attr_accessor :people_count, :email, :phone, :people, :adults, :children, :infants, :validating_carrier, :commission
      def action_codes
        {:NOP => 0, :ET => 10, :ER => 11, :ETK => 12, :ERK => 13, :EF => 14, :ETX => 15, :ERX => 16, :IG => 20, :IR => 21, :STOP => 267, :WARNINGS => 30, :SHORT => 50}
      end
      attr_accessor_with_default :pnr_action, :ER
      attr_accessor :recommendation #сейчас не используется

      def initialize(opts)
        if opts.is_a? Hash
          super
        else
          @people_count = opts.people_count
          @email = opts.email
          @phone = opts.phone
          @people = opts.people
          @adults = opts.adults
          @children = opts.children
          @infants = opts.infants
          @validating_carrier = opts.validating_carrier
          @commission = opts.commission
        end
      end

      def tk_xl_date
        (Time.now.hour < 17 ? Date.today + 1.day : Date.today + 2.days).strftime("%d%m%y")
      end

    end
  end
end


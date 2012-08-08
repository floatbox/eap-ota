module Amadeus
  module Request
    class FarePricePNRWithBookingClass < Amadeus::Request::Base
      attr_accessor :validating_carrier, :unifares

      def initialize(*)
        @unifares = true
        super
      end

    end
  end
end

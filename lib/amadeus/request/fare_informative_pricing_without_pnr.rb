module Amadeus
  module Request
    class FareInformativePricingWithoutPNR < Amadeus::Request::Base
      attr_accessor :people_count, :recommendation, :booking_class

      def flights
        recommendation.journey.flights
      end

      def validating_carrier
       recommendation.validating_carrier_iata
      end

      private

      def booking_class_for_flight fl
        booking_class || recommendation.booking_class_for_flight(fl)
      end
    end
  end
end
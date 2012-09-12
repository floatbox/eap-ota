module Amadeus
  module Request
    class FareInformativePricingWithoutPNR < Amadeus::Request::Base
      attr_accessor :people_count, :recommendation, :booking_class, :booking_classes

      def flights
        recommendation.journey.flights
      end

      def validating_carrier
       recommendation.validating_carrier_iata
      end

      private

      def booking_class_for_flight fl
        if booking_classes.present?
          i = recommendation.flights.index fl
          booking_classes[i]
        else
          booking_class || recommendation.booking_class_for_flight(fl)
        end
      end
    end
  end
end

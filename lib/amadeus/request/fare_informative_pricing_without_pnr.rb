module Amadeus
  module Request
    class FareInformativePricingWithoutPNR < Amadeus::Request::Base
      attr_accessor :people_count, :recommendation

      def flights
        recommendation.journey.flights
      end

      def validating_carrier
       recommendation.validating_carrier_iata
      end
    end
  end
end
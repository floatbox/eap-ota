module Amadeus
  module Request
    class FareInformativePricingWithoutPNR < Amadeus::Request::Base
      attr_accessor :people_count, :flights, :validating_carrier

    end
  end
end
module Amadeus
  module Request
    class FarePricePNRWithBookingClass < Amadeus::Request::Base
      attr_accessor :validating_carrier
    end
  end
end
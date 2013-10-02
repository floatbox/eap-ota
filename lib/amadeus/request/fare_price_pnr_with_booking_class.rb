module Amadeus
  module Request
    class FarePricePNRWithBookingClass < Amadeus::Request::Base
      attr_accessor :validating_carrier, :unifares, :request_options

      def initialize(*)
        @unifares = true
        @request_options = ['ETK', 'RP']
        super
      end

    end
  end
end

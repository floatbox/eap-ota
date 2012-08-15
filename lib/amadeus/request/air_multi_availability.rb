module Amadeus
  module Request
    class AirMultiAvailability < Amadeus::Request::Base
      attr_accessor :flight, :cabin

      def converted_cabin
        {Y: 3, M: 3, W: 3, C: 2, F: 1}[cabin.to_sym] if cabin
      end
    end
  end
end

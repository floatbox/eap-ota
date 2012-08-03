module Amadeus
  module Request
    class AirRetrieveSeatMap < Amadeus::Request::Base
      attr_accessor :flight, :booking_class

    end
  end
end

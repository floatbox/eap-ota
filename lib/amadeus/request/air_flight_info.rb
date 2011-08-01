module Amadeus
  module Request
    class AirFlightInfo < Amadeus::Request::Base
      attr_accessor :date, :carrier, :number
    end
  end
end

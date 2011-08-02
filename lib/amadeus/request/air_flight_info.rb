module Amadeus
  module Request
    class AirFlightInfo < Amadeus::Request::Base
      attr_accessor :date, :carrier, :number, :departure_iata, :arrival_iata
    end
  end
end

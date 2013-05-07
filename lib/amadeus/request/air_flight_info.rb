module Amadeus
  module Request
    class AirFlightInfo < Amadeus::Request::Base
      attr_accessor :date, :carrier, :number, :departure_iata, :arrival_iata

      # можно передать просто существующий Flight, ради апдейта
      def flight=(flight)
        @carrier = flight.marketing_carrier_iata
        @number = flight.flight_number
        @departure_iata = flight.departure_iata
        @arrival_iata = flight.arrival_iata
        @date = flight.dept_date
      end

    end
  end
end

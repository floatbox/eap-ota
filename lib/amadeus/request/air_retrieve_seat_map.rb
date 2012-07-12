module Amadeus
  module Request
    class AirRetrieveSeatMap < Amadeus::Request::Base
      attr_accessor :marketing_carrier_iata, :departure_date, :departure_iata, :arrival_iata, :flight_number

    end
  end
end

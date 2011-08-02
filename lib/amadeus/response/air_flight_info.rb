# encoding: utf-8
module Amadeus
  module Response
    class AirFlightInfo < Amadeus::Response::Base

      def flight
        Flight.new(
          :operating_carrier_iata => (xpath("//r:companyDetails/r:operatingCompany").to_s ||
              xpath("//r:companyDetails/r:marketingCompany").to_s),
          :marketing_carrier_iata => xpath("//r:companyDetails/r:marketingCompany").to_s,
          :departure_iata =>         xpath("//r:boardPointDetails/r:trueLocationId").to_s,
          :departure_term =>         xpath("//r:departureStationInfo/r:terminal").to_s,
          :arrival_iata =>           xpath("//r:offPointDetails/r:trueLocationId").to_s,
          :arrival_term =>           xpath("//r:arrivalStationInfo/r:terminal").to_s,
          :flight_number =>          xpath("//r:flightNumber").to_s,
          :arrival_date =>           xpath("//r:flightDate/r:arrivalDate").last.to_s,
          :arrival_time =>           xpath("//r:flightDate/r:arrivalTime").last.to_s,
          :departure_date =>         xpath("//r:flightDate/r:departureDate").to_s,
          :departure_time =>         xpath("//r:flightDate/r:departureTime").to_s,
          :equipment_type_iata =>    xpath("//r:legDetails/r:equipment").to_s,
          # высчитывается из technical_stops
          :technical_stop_count =>   xpath("//r:legDetails/r:numberOfStops").to_i || 0,
          :technical_stops => parse_technical_stops
        )
      end

      def parse_technical_stops
        (xpath('//r:boardPointAndOffPointDetails')[1..-2]).map do |pd|
          TechnicalStop.new(
            :departure_time => pd.xpath('r:generalFlightInfo/r:flightDate/r:departureTime').to_s,
            :departure_date => pd.xpath('r:generalFlightInfo/r:flightDate/r:departureDate').to_s,
            :arrival_time => pd.xpath('r:generalFlightInfo/r:flightDate/r:arrivalTime').to_s,
            :arrival_date => pd.xpath('r:generalFlightInfo/r:flightDate/r:arrivalDate').to_s,
            :location_iata => pd.xpath('r:generalFlightInfo/r:boardPointDetails/r:trueLocationId').to_s
          )
        end
      end

    end
  end
end


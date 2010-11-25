module Amadeus
  module Response
    class AirSellFromRecommendation < Amadeus::Response::Base

      # FIXME нужно разобраться со statusCode - когда все хорошо, а когда - нет
      # возможно, не только OK подходит
      def segments_confirmed?
        xpath('//r:segmentInformation/r:actionDetails/r:statusCode').every.to_s.uniq == ['OK']
      end

      # апдейтит недостающую инфу в рекомендации
      # TODO можно чище сделать
      def fill_itinerary!(segments)
        xpath('//r:itineraryDetails').each_with_index do |s, i|
          parse_flights(s, segments[i])
        end
      end

      private

      def parse_flights(fs, segment)
        fs.xpath('r:segmentInformation').each_with_index {|fl, i|
          flight = segment.flights[i]
          #flight.marketing_carrier_iata ||= fl.xpath("r:flightDetails/r:companyDetails/r:marketingCompany").to_s
          flight.departure_term = fl.xpath("r:apdSegment/r:departureStationInfo/r:terminal").to_s
          flight.arrival_term = fl.xpath("r:apdSegment/r:arrivalStationInfo/r:terminal").to_s
          if fl.xpath("r:flightDetails/r:flightDate/r:arrivalDate").present?
            flight.arrival_date = fl.xpath("r:flightDetails/r:flightDate/r:arrivalDate").to_s
          elsif fl.xpath("r:flightDetails/r:flightDate/r:dateVariation").present?
            flight.arrival_date = (DateTime.strptime( flight.departure_date, '%d%m%y' ) + 1.day).strftime('%d%m%y')
          else
            flight.arrival_date = flight.departure_date
          end
          flight.arrival_time = fl.xpath("r:flightDetails/r:flightDate/r:arrivalTime").to_s
          flight.arrival_time = '0' + flight.arrival_time if flight.arrival_time.length < 4
          flight.departure_time = fl.xpath("r:flightDetails/r:flightDate/r:departureTime").to_s
          flight.departure_time = '0' + flight.departure_time if flight.departure_time.length < 4
          flight.equipment_type_iata = fl.xpath("r:apdSegment/r:legDetails/r:equipment").to_s
        }
      end

    end
  end
end

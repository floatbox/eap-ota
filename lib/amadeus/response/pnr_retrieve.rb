module Amadeus
  module Response
    class PNRRetrieve < Amadeus::Response::Base

      def flights
        xpath("//r:itineraryInfo[r:segmentName='AIR']").map do |fi|
            Flight.new(
              :operating_carrier_iata => fi.xpath("r:travelProduct/r:companyDetail/r:identification").to_s,
              :departure_iata =>         fi.xpath("r:travelProduct/r:boardpointDetail/r:cityCode").to_s,
              :arrival_iata =>           fi.xpath("r:travelProduct/r:offpointDetail/r:cityCode").to_s,
              :flight_number =>          fi.xpath("r:travelProduct/r:productDetails/r:identification").to_s,
              :arrival_date =>           fi.xpath("r:travelProduct/r:product/r:arrDate").to_s,
              :arrival_time =>           fi.xpath("r:travelProduct/r:product/r:arrTime").to_s,
              :departure_date =>         fi.xpath("r:travelProduct/r:product/r:depDate").to_s,
              :departure_time =>         fi.xpath("r:travelProduct/r:product/r:depTime").to_s,
              :class_of_service =>       fi.xpath("r:travelProduct/r:productDetails/r:classOfService").to_s,
              :equipment_type_iata =>    fi.xpath("r:flightDetail/r:productDetails/r:equipment").to_s,
              :departure_term =>         fi.xpath("r:flightDetail/r:departureInformation/r:departTerminal").to_s,
              :warning =>                fi.xpath("r:errorInfo/r:errorfreeFormText/r:text").to_s
            )
        end
      end

      def passengers
        xpath('//r:travellerInformation').map do |ti|
          Person.new(:first_name => (ti / 'r:passenger/r:firstName').to_s,
                     :last_name => (ti / 'r:traveller/r:surname').to_s)
        end
      end

      def email
        xpath('//r:otherDataFreetext[r:freetextDetail/r:type="P02"]/r:longFreetext').to_s
      end

      def phone
        xpath('//r:otherDataFreetext[r:freetextDetail/r:type=3]/r:longFreetext').to_s
      end

      def ticket_number
        # PAX 257-9748002002/ETOS/RUB9880/30SEP10/MOWR2290Q/00000000
        fa = xpath('//r:otherDataFreetext[r:freetextDetail/r:type="P06"]/r:longFreetext').to_s
        return unless fa
        fa =~ %r|PAX ([^/]*)|
        $1
      end

      # def prices
        # можно вытащить аналогично fare_price_pnr_with_booking_class.rb
      # end

    end
  end
end

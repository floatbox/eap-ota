# encoding: utf-8
module Amadeus
  module Response
    class PNRRetrieve < Amadeus::Response::Base

      def flights
        xpath("//r:itineraryInfo[r:elementManagementItinerary/r:segmentName='AIR']").map do |fi|
            Flight.new(
              :marketing_carrier_iata => fi.xpath("r:travelProduct/r:companyDetail/r:identification").to_s,
              :departure_iata =>         fi.xpath("r:travelProduct/r:boardpointDetail/r:cityCode").to_s,
              :arrival_iata =>           fi.xpath("r:travelProduct/r:offpointDetail/r:cityCode").to_s,
              :flight_number =>          fi.xpath("r:travelProduct/r:productDetails/r:identification").to_s,
              :arrival_date =>           fi.xpath("r:travelProduct/r:product/r:arrDate").to_s,
              :arrival_time =>           fi.xpath("r:travelProduct/r:product/r:arrTime").to_s,
              :departure_date =>         fi.xpath("r:travelProduct/r:product/r:depDate").to_s,
              :departure_time =>         fi.xpath("r:travelProduct/r:product/r:depTime").to_s,
              # :class_of_service =>       fi.xpath("r:travelProduct/r:productDetails/r:classOfService").to_s,
              :equipment_type_iata =>    fi.xpath("r:flightDetail/r:productDetails/r:equipment").to_s,
              :departure_term =>         fi.xpath("r:flightDetail/r:departureInformation/r:departTerminal").to_s,
              :warning =>                fi.xpath("r:errorInfo/r:errorfreeFormText/r:text").to_s
            )
        end.find_all(&:marketing_carrier_iata)#для пустых перелетов (случай сложного маршрута)
        # FIXME найти более подходящий xpath для отбрасывания сервисных сегментов.
      end

      # временное решение
      def booking_classes
        xpath("//r:itineraryInfo[r:elementManagementItinerary/r:segmentName='AIR']" +
              "[r:travelProduct/r:companyDetail/r:identification]" +
              "/r:travelProduct/r:productDetails/r:classOfService"
             ).map(&:to_s)
      end

      def passengers
        xpath('//r:travellerInformation').map do |ti|
          surname = (ti / 'r:traveller/r:surname').to_s
          (ti / 'r:passenger').map do |passenger|
              Person.new(:first_name => passenger.xpath('r:firstName').to_s,
                         :last_name => surname,
                         :passport => passport_number(passenger),
                         :number_in_amadeus => (ti / '../../r:elementManagementPassenger/r:lineNumber').to_s
                         )
          end
        end.flatten
      end

      def passport_number(passenger_node)
        number = (passenger_node / '../../../r:elementManagementPassenger/r:reference/r:number').to_s
        need_infant = (passenger_node / 'r:type').to_s == 'INF'
        xpath( "//r:dataElementsIndiv[
           r:referenceForDataElement/r:reference[r:qualifier='PT'][r:number=#{number}]
          ]/r:serviceRequest/r:ssr[r:type='DOCS']/r:freeText"
        ).each do |ssr_text|
          passport, sex = ssr_text.to_s.split('/').values_at(2, 5)
          return passport if need_infant == (sex == 'FI' || sex == 'MI')
        end
      end

      def email
        xpath('//r:otherDataFreetext[r:freetextDetail/r:type="P02"]/r:longFreetext').to_s
      end

      def phone
        xpath('//r:otherDataFreetext[r:freetextDetail/r:type=3]/r:longFreetext').to_s
      end

      def ticket_numbers
        # PAX 257-9748002002/ETOS/RUB9880/30SEP10/MOWR2290Q/00000000
        xpath('//r:otherDataFreetext[r:freetextDetail/r:type="P06"]/r:longFreetext').map do |fa|
          fa.to_s =~ %r<(?:PAX|INF) ([^/]*)>
          $1
        end
      end

      # def prices
        # можно вытащить аналогично fare_price_pnr_with_booking_class.rb
      # end

    end
  end
end

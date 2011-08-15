# encoding: utf-8
module Amadeus
  module Response
    class PNRRetrieve < Amadeus::Response::Base

      # FIXME может быть не одно на бронирование?
      # проверять что принадлежит амадеусу (1A)
      def pnr_number
        xpath('//r:controlNumber').to_s
      end

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

      def all_segments_available?
        xpath('//r:relatedProduct/r:status').every.to_s - ['HK', 'KK'] == []
      end

      def additional_pnr_numbers
        xpath('//r:itineraryReservationInfo/r:reservation').inject({}) do |result, ri|
          marketing_carrier = ri.xpath('r:companyId').to_s
          pnr_number = ri.xpath('r:controlNumber').to_s
          result.merge({marketing_carrier => pnr_number})
        end
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
          surname = ti.xpath('r:traveller/r:surname').to_s
          ti.xpath('r:passenger').map do |passenger|
              passenger_ref = (passenger / '../../../r:elementManagementPassenger/r:reference/r:number').to_i
              need_infant = (passenger / 'r:type').to_s == 'INF'
              Person.new(:first_name => passenger.xpath('r:firstName').to_s,
                         :last_name => surname,
                         :passenger_ref => passenger_ref,
                         :passport => passport(passenger_ref, need_infant),
                         :ticket => ticket(passenger_ref, need_infant),
                         :number_in_amadeus => (ti / '../../r:elementManagementPassenger/r:lineNumber').to_s,
                         :infant_or_child => need_infant ? 'i' : nil
                         )
          end
        end.flatten
      end

      def passport(passenger_ref, need_infant=false)
        xpath( "//r:dataElementsIndiv[
            r:referenceForDataElement/r:reference[r:qualifier='PT'][r:number=#{passenger_ref}]
          ]/r:serviceRequest/r:ssr[r:type='DOCS']/r:freeText"
        ).each do |ssr_text|
          passport, sex = ssr_text.to_s.split('/').values_at(2, 5)
          return passport if need_infant == (sex == 'FI' || sex == 'MI')
        end
        return
      end

      # PAX 257-9748002002/ETOS/RUB9880/30SEP10/MOWR2290Q/00000000
      def ticket(passenger_ref, need_infant=false)
        xpath( "//r:dataElementsIndiv[
            r:referenceForDataElement/r:reference[r:qualifier='PT'][r:number=#{passenger_ref}]
          ]/r:otherDataFreetext[r:freetextDetail/r:type='P06']/r:longFreetext"
        ).each do |fa|
          fa.to_s =~ %r<(PAX|INF) ([^/]*)>
          return $2 if need_infant == ($1 == 'INF')
        end
        return
      end

      def email
        xpath('//r:otherDataFreetext[r:freetextDetail/r:type="P02"]/r:longFreetext').to_s
      end

      def phone
        xpath('//r:otherDataFreetext[r:freetextDetail/r:type=3]/r:longFreetext').to_s
      end


      # def prices
        # можно вытащить аналогично fare_price_pnr_with_booking_class.rb
      # end

    end
  end
end


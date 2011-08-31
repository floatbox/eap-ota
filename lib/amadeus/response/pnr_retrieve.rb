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
              ticket_hash = ticket(passenger_ref, need_infant) || {}
              ticket_hash.delete(:inf)
              Person.new(:first_name => passenger.xpath('r:firstName').to_s,
                         :last_name => surname,
                         :passenger_ref => passenger_ref,
                         :passport => passport(passenger_ref, need_infant),
                         :ticket => ticket_hash.present? && ("#{ticket_hash[:code]}-#{ticket_hash[:number]}") || nil,
                         :ticket_hash => ticket_hash,
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
          res = parsed_ticket_string(fa.to_s)
          return res if res && need_infant == (res[:inf] == 'INF')
        end
        return
      end

      def parsed_ticket_string(s)
        m = s.to_s.match(/(PAX|INF) (\d+)-([\d-]+)\/\w([TRV])(\w{2})\/\w+\/(\w+)\/(\w+)\/(\d+)/)
        if m
          return({
            :number => m[3],
            :code => m[2],
            :status => {'T' => 'ticketed', 'V' => 'voided', 'R' => 'returned'}[m[4]],
            :ticketed_date => Date.strptime(m[6], '%d%h%y'),
            :validating_carrier => m[5],
            :office_id => m[7],
            :validator => m[8],
            :inf => m[1]
            })
        end
      end

      def email
        xpath('//r:otherDataFreetext[r:freetextDetail/r:type="P02"]/r:longFreetext').to_s
      end

      def phone
        xpath('//r:otherDataFreetext[r:freetextDetail/r:type=3]/r:longFreetext').to_s
      end

      # их может быть несколько. возвращаем первый найденный
      def validating_carrier_code
        xpath('//r:dataElementsIndiv[r:elementManagementData/r:segmentName="FV"]/r:otherDataFreetext/r:longFreetext').to_s \
          .try(:gsub, /INF |PAX /, '')
      end

      # def prices
        # можно вытащить аналогично fare_price_pnr_with_booking_class.rb
      # end

    end
  end
end


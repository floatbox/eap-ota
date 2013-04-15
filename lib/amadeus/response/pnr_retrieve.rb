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
        flights_hash.values.map{|v| Flight.new(v)}
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
              tickets_array = ticket(passenger_ref, need_infant) || []
              tickets_array.every.delete(:inf)
              Person.new(:first_name => passenger.xpath('r:firstName').to_s,
                         :last_name => surname,
                         :passenger_ref => passenger_ref,
                         :passport => passport(passenger_ref, need_infant),
                         :tickets => correct_passenger_tickets(tickets_array),
                         :number_in_amadeus => (ti / '../../r:elementManagementPassenger/r:lineNumber').to_s,
                         :infant => need_infant
                         )
          end
        end.flatten
      end

      def correct_passenger_tickets(tickets_array)
        tickets_array.map do |ticket_hash|
          t = Ticket.find_or_initialize_by_code_and_number_and_kind(ticket_hash[:code],
                                                            ticket_hash[:number],
                                                            'ticket')
          t.status ||= 'ticketed'
          t
        end.delete_if {|t| t.status != 'ticketed'}.uniq

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
        ).each_with_object([]) do |fa, memo|
          res = parsed_ticket_string(fa.to_s)
          memo << res if res && need_infant == (res[:inf] == 'INF')
        end
      end

      def parsed_exchange_string(s)
        m = s.to_s.match(/(PAX|INF)?.*\/(\d{3})-([\d-]{10,14})(\w){3}([-\*]\w{3})?/)
        if m
          return({:number => m[3], :code => m[2], :inf => m[1]})
        end
      end

      def parsed_ticket_string(s)
        m = s.to_s.match(
          %r{
            (?<inf>PAX|INF)\ (?<code> \d+ )-(?<number> [\d-]+ )
            / [DE] (?<status> [TRV] ) (?<validating_carrier> \w{2} )
            /? [^/]*
            / (?<ticketed_date> \w+ )
            / (?<office_id> \w+ )
            / (?<validator> \d+ )
          }x
        )
        if m
          return({
            :number => m[:number],
            :code => m[:code],
            :status => {'T' => 'ticketed', 'V' => 'voided', 'R' => 'returned'}[m[:status]],
            :ticketed_date => Date.strptime(m[:ticketed_date], '%d%h%y'),
            :validating_carrier => m[:validating_carrier],
            :office_id => m[:office_id],
            :validator => m[:validator],
            :inf => m[:inf]
            })
        end
      end

      def flights_hash
        @flights_hash ||= xpath("//r:itineraryInfo[r:elementManagementItinerary/r:segmentName='AIR']").inject( ActiveSupport::OrderedHash.new) do |res, fi|
          ref = fi.xpath("r:elementManagementItinerary/r:reference/r:number").to_i
          fh = {
            :marketing_carrier_iata => fi.xpath("r:travelProduct/r:companyDetail/r:identification").to_s,
            :departure_iata =>         fi.xpath("r:travelProduct/r:boardpointDetail/r:cityCode").to_s,
            :arrival_iata =>           fi.xpath("r:travelProduct/r:offpointDetail/r:cityCode").to_s,
            :flight_number =>          fi.xpath("r:travelProduct/r:productDetails/r:identification").to_s,
            :arrival_date =>           fi.xpath("r:travelProduct/r:product/r:arrDate").to_s,
            :arrival_time =>           fi.xpath("r:travelProduct/r:product/r:arrTime").to_s,
            :departure_date =>         fi.xpath("r:travelProduct/r:product/r:depDate").to_s,
            :departure_time =>         fi.xpath("r:travelProduct/r:product/r:depTime").to_s,
            :equipment_type_iata =>    fi.xpath("r:flightDetail/r:productDetails/r:equipment").to_s,
            :departure_term =>         fi.xpath("r:flightDetail/r:departureInformation/r:departTerminal").to_s,
            :cabin =>                  fi.xpath("r:travelProduct/r:productDetails/r:classOfService").to_s,
            :warning =>                fi.xpath("r:errorInfo/r:errorfreeFormText/r:text").to_s,
            :amadeus_ref => ref
          }
          if fh[:marketing_carrier_iata] #для пустых перелетов (случай сложного маршрута)
            res.merge({ref => fh})
          else
            res
          end
        end
      end

      def tickets
        @tickets ||= xpath( "//r:dataElementsIndiv[r:referenceForDataElement/r:reference[r:qualifier='PT']]/r:otherDataFreetext[r:freetextDetail/r:type='P06']/r:longFreetext"
        ).inject({}) do |res, fa|
          passenger_ref = fa.xpath("../../r:referenceForDataElement/r:reference[r:qualifier='PT']/r:number").to_i
          segments_refs = fa.xpath("../../r:referenceForDataElement/r:reference[r:qualifier='ST']/r:number").every.to_i.sort
          passenger_elem = xpath("//r:travellerInfo[r:elementManagementPassenger/r:reference[r:qualifier='PT'][r:number=#{passenger_ref}]]")
          ticket_hash = parsed_ticket_string(fa.to_s)
          infant_flag = ticket_hash.delete(:inf) == 'INF' ? 'i': 'a'
          if infant_flag != 'i'
            passenger_last_name = passenger_elem.xpath('r:passengerData/r:travellerInformation/r:traveller/r:surname').to_s
            passenger_first_name = passenger_elem.xpath('r:passengerData/r:travellerInformation/r:passenger/r:firstName').to_s
          else
            passenger_last_name = passenger_elem.xpath('r:passengerData/r:travellerInformation/r:passenger[r:type="INF"]/../r:traveller/r:surname').to_s ||
              passenger_elem.xpath('r:passengerData/r:travellerInformation/r:traveller/r:surname').to_s
            passenger_first_name = passenger_elem.xpath('r:passengerData/r:travellerInformation/r:passenger[r:type="INF"]/r:firstName').to_s
          end
          flights_array = segments_refs.sort.map do |sr|
            Flight.new(flights_hash[sr]) if flights_hash[sr]
          end.compact
          ticket_key = [[passenger_ref, infant_flag], segments_refs]
          res.merge({ticket_key => ticket_hash.merge({
              :first_name => passenger_first_name,
              :passport => passport(passenger_ref, infant_flag == 'i'),
              :last_name => passenger_last_name,
              :flights => flights_array
            })})
        end
      end

      def exchanged_tickets
        @exchanged_tickets ||= xpath( "//r:dataElementsIndiv[r:elementManagementData/r:reference[r:qualifier='OT']]/r:otherDataFreetext[r:freetextDetail/r:type='45']/r:longFreetext"
        ).inject({}) do |res, fa|
          ticket_hash = parsed_exchange_string(fa.to_s)
          infant_flag = ticket_hash.delete(:inf) == 'INF' ? 'i': 'a'
          passenger_ref = fa.xpath("../../r:referenceForDataElement/r:reference[r:qualifier='PT']/r:number").to_i || tickets.keys.find{|(_, flag), _| flag == infant_flag}[0][0]
          passenger_elem = xpath("//r:travellerInfo[r:elementManagementPassenger/r:reference[r:qualifier='PT'][r:number=#{passenger_ref}]]")

          segments_refs = fa.xpath("../../r:referenceForDataElement/r:reference[r:qualifier='ST']/r:number").every.to_i.sort
          if segments_refs.blank?
            # Данные по обменяному билету бывают кривыми
            new_ticket = tickets.find{|k, v| k[0] == [passenger_ref, infant_flag] && v[:number] != ticket_hash[:number]}
            segments_refs = new_ticket[0][1] if new_ticket
          end
          res.merge({[[passenger_ref, infant_flag], segments_refs] => ticket_hash}) if segments_refs.present?
        end
      end

      def complex_tickets?
        xpath("//r:dataElementsIndiv[
            r:referenceForDataElement/r:reference[r:qualifier='PT']
          ]/r:otherDataFreetext[r:freetextDetail/r:type='P06']/r:longFreetext").count != xpath("//r:passenger").count
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

      def agent_commission
        fm = xpath('//r:dataElementsIndiv[r:elementManagementData/r:segmentName="FM"]/r:otherDataFreetext/r:longFreetext').to_s
        return unless fm
        if m = fm.match(/(\d+)(A)?/)
          m[2] ? m[1] : m[1] + '%'
        end
      end

      # результат PNR_TransferOwnership. Не проверяет queue office и прочее.
      def responsibility_office
        xpath('//r:securityInformation/r:responsibilityInformation/r:officeId').to_s
      end
    end
  end
end


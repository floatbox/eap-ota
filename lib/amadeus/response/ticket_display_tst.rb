# encoding: utf-8
module Amadeus
  module Response
    class TicketDisplayTST < Amadeus::Response::Base
      def prices_with_refs
        xpath('//r:fareList/r:paxSegReference/r:refDetails[r:refQualifier="PT" or r:refQualifier="P" or r:refQualifier="PA" or r:refQualifier="PI"]').inject({}) do |memo, rd|
          passenger_ref = rd.xpath('r:refNumber').to_i
          fi = rd.xpath('../../r:fareDataInformation')
          infant_flag = rd.xpath('../../r:statusInformation/r:firstStatusDetails[r:tstFlag="INF"]').present?
          price_fare = (
              fi.xpath('r:fareDataSupInformation[r:fareDataQualifier="B"][r:fareCurrency="RUB"]/r:fareAmount').to_i ||
              fi.xpath('r:fareDataSupInformation[r:fareDataQualifier="E"][r:fareCurrency="RUB"]/r:fareAmount').to_i
            ).to_i
          price_tax = fi.xpath('r:fareDataSupInformation[r:fareDataQualifier="712"][r:fareCurrency="RUB"]/r:fareAmount').to_i.to_i - price_fare
          segments_refs = rd.xpath('../../r:segmentInformation[r:segDetails/r:ticketingStatus!="NO"]/r:segmentReference/r:refDetails[r:refQualifier="S"]/r:refNumber').every.to_i.sort
          memo.merge([[passenger_ref, infant_flag ? 'i' : 'a'], segments_refs] => {:price_fare => price_fare, :price_tax => price_tax, :price_fare_base => price_fare})
        end
      end

      def baggage_with_refs
        @baggage_with_refs ||= xpath('//r:fareList/r:segmentInformation/r:bagAllowanceInformation/r:bagAllowanceDetails').inject({}) do |memo, bi|
          baggage_quantity = bi.xpath('r:baggageQuantity').to_i
          baggage_weight = bi.xpath('r:baggageWeight').to_i
          baggage_type = bi.xpath('r:baggageType').to_s
          measure_unit = bi.xpath('r:measureUnit').to_s
          segment_ref = bi.xpath('../../r:segmentReference/r:refDetails/r:refNumber').to_i
          memo[segment_ref] ||= {}
          passenger_refs = bi.xpath('../../../r:paxSegReference/r:refDetails/r:refNumber').every.to_i
          infant_flag = bi.xpath('../../../r:statusInformation/r:firstStatusDetails[r:tstFlag="INF"]').present? ? 'i' : 'a'
          passenger_refs.each do |pax_ref|
            if baggage_type == 'N' && baggage_quantity
              memo[segment_ref][[pax_ref, infant_flag]] = {:value => baggage_quantity, :type => 'N'}
            elsif baggage_type == 'W' && baggage_weight
              memo[segment_ref][[pax_ref, infant_flag]] = {:value => baggage_weight, :type => measure_unit}
            end
          end
          memo
        end
      end

      def baggage_for_segments
        @baggage_for_segments ||=  baggage_with_refs.inject({}) do |memo, segment_ref|
          segment_ref[1].each do |pax_key, baggage_limitations|
            if pax_key[1] == 'a'
              memo[segment_ref[0]] = baggage_limitations
            end
          end
          memo
        end
      end

      def total_fare
        prices_with_refs.values.inject(0) do |fare, prices|
          fare += prices[:price_fare]
          fare += prices[:price_fare_infant] if prices[:price_fare_infant]
          fare
        end
      end

      def total_tax
        prices_with_refs.values.inject(0) do |tax, prices|
          tax += prices[:price_tax]
          tax += prices[:price_tax_infant] if prices[:price_tax_infant]
          tax
        end
      end

      # может быть несколько, для разных сегментов и тарифов. но для целей помощи операторам - первый сойдет.
      def validating_carrier_code
        xpath('//r:carrierCode').to_s
      end

      # нужен LT. есть еще CRD - дата созания маски(?), LMD - дата модификации
      def last_tkt_date
        parse_date_element(xpath('//r:lastTktDate[r:businessSemantic="LT"]/r:dateTime'))
      end

      # количество бланков
      def blank_count
        xpath('//r:fareList/r:paxSegReference/r:refDetails[r:refQualifier="PT" or r:refQualifier="P" or r:refQualifier="PA" or r:refQualifier="PI"]').size
      end

      def error_message
        xpath('//r:applicationError/r:errorText/r:errorFreeText').to_s
      end
    end
  end
end


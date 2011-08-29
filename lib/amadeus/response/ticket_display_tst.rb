# encoding: utf-8
module Amadeus
  module Response
    class TicketDisplayTST < Amadeus::Response::Base
      def prices_with_refs
        xpath('//r:fareList/r:paxSegReference/r:refDetails[r:refQualifier="PT"]').inject({}) do |memo, rd|
          passenger_ref = rd.xpath('r:refNumber').to_i
          fi = rd.xpath('../../r:fareDataInformation')
          infant_flag = rd.xpath('../../r:statusInformation/r:firstStatusDetails[r:tstFlag="INF"]').present?
          price_fare = (
              fi.xpath('r:fareDataSupInformation[r:fareDataQualifier="B"][r:fareCurrency="RUB"]/r:fareAmount').to_i ||
              fi.xpath('r:fareDataSupInformation[r:fareDataQualifier="E"][r:fareCurrency="RUB"]/r:fareAmount').to_i
            ).to_i
          price_tax = fi.xpath('r:fareDataSupInformation[r:fareDataQualifier="712"][r:fareCurrency="RUB"]/r:fareAmount').to_i.to_i - price_fare
          if infant_flag
            memo.deep_merge(passenger_ref => {:price_fare_infant => price_fare, :price_tax_infant => price_tax})
          else
            memo.deep_merge(passenger_ref => {:price_fare => price_fare, :price_tax => price_tax})
          end
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
    end
  end
end


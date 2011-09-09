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
          segments_refs = rd.xpath('../../r:segmentInformation/r:segmentReference/r:refDetails[r:refQualifier="S"]/r:refNumber').every.to_i.sort
          if infant_flag
            memo.merge([[passenger_ref, 'i'], segments_refs] => {:price_fare => price_fare, :price_tax => price_tax})
          else
            memo.merge([[passenger_ref, 'a'], segments_refs] => {:price_fare => price_fare, :price_tax => price_tax})
          end
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

      # количество масок. количество бланков, видимо, тоже.
      # FIXME: проверить
      def fares_count
        xpath('//r:fareList').size
      end
    end
  end
end


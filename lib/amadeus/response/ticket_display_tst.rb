# encoding: utf-8
module Amadeus
  module Response
    class TicketDisplayTST < Amadeus::Response::Base
      def prices_with_refs
        xpath('//r:fareList/r:paxSegReference/r:refDetails[r:refQualifier="PT"]').inject({}) do |memo, rd|
          passenger_ref = rd.xpath('r:refNumber').to_i
          fi = rd.xpath('../../r:fareDataInformation')
          price_fare = (
              fi.xpath('r:fareDataSupInformation[r:fareDataQualifier="B"][r:fareCurrency="RUB"]/r:fareAmount').to_i ||
              fi.xpath('r:fareDataSupInformation[r:fareDataQualifier="E"][r:fareCurrency="RUB"]/r:fareAmount').to_i
            ).to_i
          price_tax = fi.xpath('r:fareDataSupInformation[r:fareDataQualifier="712"][r:fareCurrency="RUB"]/r:fareAmount').to_i.to_i - price_fare
          memo.merge(passenger_ref => {:price_fare => price_fare, :price_tax => price_tax})
        end
      end
    end
  end
end


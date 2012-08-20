# encoding: utf-8
module Amadeus
  module Response
    class FarePricePNRWithLowerFares < Amadeus::Response::Base
      def prices
        price_fare = xpath('//r:fareList/r:fareDataInformation').xpath('r:fareDataSupInformation[r:fareDataQualifier="E"][r:fareCurrency="RUB"]/r:fareAmount|
        r:fareDataSupInformation[r:fareDataQualifier="B"][r:fareCurrency="RUB"]/r:fareAmount').to_f
        price_total = xpath('//r:fareList/r:fareDataInformation/r:fareDataSupInformation[r:fareDataQualifier="712"][r:fareCurrency="RUB"]/r:fareAmount').to_f
        [price_fare, price_total - price_fare]
      end

      def new_booking_classes
        xpath('//r:segmentInformation/r:segDetails/r:segmentDetail[r:identification="AIR"]/r:classOfService').every.to_s
      end
    end
  end
end


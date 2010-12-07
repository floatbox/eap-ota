module Amadeus
  module Response
    class FarePricePNRWithBookingClass < Amadeus::Response::Base

      # копипаста. для данного запроса - не работает. нужна?
      def prices
        xpath('//r:fareList/r:fareDataInformation').collect do |pg|
          price_total = pg.xpath('r:fareDataSupInformation[r:fareDataQualifier="712"][r:fareCurrency="RUB"]/r:fareAmount').to_s.to_i
          # FIXME сделать один xpath
          price_fare = (
            pg.xpath('r:fareDataSupInformation[r:fareDataQualifier="B"][r:fareCurrency="RUB"]/r:fareAmount').to_s ||
            pg.xpath('r:fareDataSupInformation[r:fareDataQualifier="E"][r:fareCurrency="RUB"]/r:fareAmount').to_s
          ).to_i
          price_tax = price_total - price_fare
          [price_fare, price_tax]
        end
      end

      def message
        xpath('//r:applicationError/r:errorText/r:errorFreeText').to_s
      end

      def success?
        message.nil?
      end

      def fare_list_count
        xpath('//r:fareList').size
      end
    end
  end
end

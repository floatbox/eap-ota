# encoding: utf-8
module Amadeus
  module Response
    class FarePricePNRWithBookingClass < Amadeus::Response::Base

      # копипаста. для данного запроса - не работает. нужна?
      def prices
        xpath('//r:fareList/r:fareDataInformation').collect do |pg|
          people_count = pg.xpath('../r:paxSegReference/r:refDetails').count
          price_total = pg.xpath('r:fareDataSupInformation[r:fareDataQualifier="712"][r:fareCurrency="RUB"]/r:fareAmount').to_s.to_i * people_count
          # FIXME сделать один xpath
          price_fare = (
            pg.xpath('r:fareDataSupInformation[r:fareDataQualifier="B"][r:fareCurrency="RUB"]/r:fareAmount').to_s ||
            pg.xpath('r:fareDataSupInformation[r:fareDataQualifier="E"][r:fareCurrency="RUB"]/r:fareAmount').to_s
          ).to_i * people_count
          price_tax = price_total - price_fare
          [price_fare, price_tax]
        end.inject {|a, pr| [a[0] + pr[0], a[1] + pr[1]]}
      end

      def message
        xpath('//r:applicationError/r:errorText/r:errorFreeText').to_s
      end

      def success?
        message.nil?
      end

      def fares_count
        xpath('//r:fareList').size
      end
    end
  end
end

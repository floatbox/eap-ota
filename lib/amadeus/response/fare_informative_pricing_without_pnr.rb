# encoding: utf-8
module Amadeus
  module Response
    class FareInformativePricingWithoutPNR < Amadeus::Response::Base

      def prices
        price_total = 0
        price_fare = 0
        # FIXME почему то амадеус возвращает цену для одного человека, даже если указано несколько
        xpath('//r:pricingGroupLevelGroup').each do |pg|
          passengers_in_group = pg.xpath('r:numberOfPax/r:segmentControlDetails/r:numberOfUnits').to_i
          price_total += pg.xpath('r:fareInfoGroup/r:fareAmount/r:otherMonetaryDetails[r:typeQualifier="712"][r:currency="RUB"]/r:amount').to_f * passengers_in_group
          # FIXME сделать один xpath
          price_fare += (
            pg.xpath('r:fareInfoGroup/r:fareAmount/r:otherMonetaryDetails[r:typeQualifier="E"][r:currency="RUB"]/r:amount').to_f ||
            pg.xpath('r:fareInfoGroup/r:fareAmount/r:monetaryDetails[r:typeQualifier="B"][r:currency="RUB"]/r:amount').to_f
          ) * passengers_in_group
        end

        # FIXME не очень надежный признак
        # есть какой-то xpath для ошибок?
        return if price_total == 0 || price_fare == 0

        price_tax = price_total - price_fare
        return price_fare, price_tax
      end

      def recommendations rec
        new_rec = Recommendation.new(:variants => rec.variants, :booking_classes => rec.booking_classes, :cabins => rec.cabins)
        new_rec.price_fare, new_rec.price_tax = prices
        [new_rec]
      end
    end
  end
end

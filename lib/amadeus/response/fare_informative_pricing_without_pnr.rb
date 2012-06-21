# encoding: utf-8
module Amadeus
  module Response
    class FareInformativePricingWithoutPNR < Amadeus::Response::Base

      def all_prices
        # FIXME почему то амадеус возвращает цену для одного человека, даже если указано несколько
        xpath('//r:pricingGroupLevelGroup').map do |pricing_group|
          prices pricing_group
        end
      end

      def prices pricing_group
        passengers_in_group = pricing_group.xpath('r:numberOfPax/r:segmentControlDetails/r:numberOfUnits').to_i
          price_total = pricing_group.xpath('r:fareInfoGroup/r:fareAmount/r:otherMonetaryDetails[r:typeQualifier="712"][r:currency="RUB"]/r:amount').to_f * passengers_in_group
          # FIXME сделать один xpath
          price_fare = (
            pricing_group.xpath('r:fareInfoGroup/r:fareAmount/r:otherMonetaryDetails[r:typeQualifier="E"][r:currency="RUB"]/r:amount').to_f ||
            pricing_group.xpath('r:fareInfoGroup/r:fareAmount/r:monetaryDetails[r:typeQualifier="B"][r:currency="RUB"]/r:amount').to_f
          ) * passengers_in_group
          # FIXME не очень надежный признак
          # есть какой-то xpath для ошибок?
          return if price_total == 0 || price_fare == 0
          price_tax = price_total - price_fare
          [price_fare, price_tax]
      end

      def recommendations rec
        adults.map do |adult|
          new_rec = Recommendation.new(:variants => rec.variants)
          new_rec.booking_classes = adult.xpath('r:fareInfoGroup/r:segmentLevelGroup/r:cabinGroup/r:cabinSegment/r:bookingClassDetails/r:designator').map(&:to_s)
          new_rec.cabins = adult.xpath('r:fareInfoGroup/r:segmentLevelGroup/r:cabinGroup/r:cabinSegment/r:bookingClassDetails/r:option').map(&:to_s)

          #считаем тотал для каждой из групп пассажиров
          adult_price_fare, adult_price_tax = prices adult
          child_price_fare, child_price_tax, infant_price_fare, infant_price_tax = 0,0,0,0
          child_price_fare, child_price_tax = prices children.pop if children.present?
          infant_price_fare, infant_price_tax = prices infants.pop if infants.present?

          new_rec.price_fare = adult_price_fare + child_price_fare + infant_price_fare
          new_rec.price_tax = adult_price_tax + child_price_tax + infant_price_tax
          new_rec
        end
      end

      #массив pricing_groups, соответствующих только взрослым
      def adults
        xpath('//r:pricingGroupLevelGroup').map do |pr|
          if pr.xpath('r:fareInfoGroup/r:segmentLevelGroup/r:ptcSegment/r:quantityDetails/r:unitQualifier').to_s == "ADT"
            pr
          end
        end.compact
      end

      #массив pricing_groups, соответствующих только детям
      def children
        xpath('//r:pricingGroupLevelGroup').map do |pr|
          if pr.xpath('r:fareInfoGroup/r:segmentLevelGroup/r:ptcSegment/r:quantityDetails/r:unitQualifier').to_s == "CH"
            pr
          end
        end.compact
      end

      #массив pricing_groups, соответствующих только младенцам без места
      def infants
        xpath('//r:pricingGroupLevelGroup').map do |pr|
          if pr.xpath('r:fareInfoGroup/r:segmentLevelGroup/r:ptcSegment/r:quantityDetails/r:unitQualifier').to_s == "IN"
            pr
          end
        end.compact
      end
    end
  end
end

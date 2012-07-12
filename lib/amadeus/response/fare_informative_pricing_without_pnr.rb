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

      def local_prices pricing_group
        passengers_in_group = pricing_group.xpath('r:numberOfPax/r:segmentControlDetails/r:numberOfUnits').to_i
          price_total = pricing_group.xpath('r:fareInfoGroup/r:fareAmount/r:otherMonetaryDetails[r:typeQualifier="712"][r:currency="RUB"]/r:amount').to_f * passengers_in_group
          # FIXME сделать один xpath
          price_fare = (
            pricing_group.xpath('r:fareInfoGroup/r:fareAmount/r:otherMonetaryDetails[r:typeQualifier="E"][r:currency="RUB"]/r:amount').to_f ||
            pricing_group.xpath('r:fareInfoGroup/r:fareAmount/r:monetaryDetails[r:typeQualifier="B"][r:currency="RUB"]/r:amount').to_f
          ) * passengers_in_group
          price_tax = price_total - price_fare
          [price_fare, price_tax]
      end

      def recommendations rec
        good_for_transposing = []
        max_count = [adults, infants, children].map(&:count).max

        [adults, infants, children].each do |age_group|
          age_group.fill( age_group.first, (age_group.count...max_count)) if age_group.count < max_count
          good_for_transposing << age_group if age_group.present?
        end

        good_for_transposing.transpose.map do |complex_group|
          complex_group.compact!
          new_rec = Recommendation.new(:variants => rec.variants)
          new_rec.booking_classes = complex_group.first.xpath('r:fareInfoGroup/r:segmentLevelGroup/r:cabinGroup/r:cabinSegment/r:bookingClassDetails/r:designator').map(&:to_s)
          new_rec.cabins = complex_group.first.xpath('r:fareInfoGroup/r:segmentLevelGroup/r:cabinGroup/r:cabinSegment/r:bookingClassDetails/r:option').map(&:to_s)
          new_rec.price_fare, new_rec.price_tax = complex_group.map{|cg|local_prices cg}.transpose.map{|x| x.reduce(:+)}
          new_rec
        end
      end

      #массив pricing_groups, соответствующих только взрослым
      def adults
        xpath("//r:pricingGroupLevelGroup[r:fareInfoGroup/r:segmentLevelGroup/r:ptcSegment/r:quantityDetails/r:unitQualifier='ADT']")
      end

      #массив pricing_groups, соответствующих только детям
      def children
        xpath("//r:pricingGroupLevelGroup[r:fareInfoGroup/r:segmentLevelGroup/r:ptcSegment/r:quantityDetails/r:unitQualifier='CH']")
      end

      #массив pricing_groups, соответствующих только младенцам без места
      def infants
        xpath("//r:pricingGroupLevelGroup[r:fareInfoGroup/r:segmentLevelGroup/r:ptcSegment/r:quantityDetails/r:unitQualifier='IN']")
      end
    end
  end
end

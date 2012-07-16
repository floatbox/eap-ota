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
          price_fare += pg.xpath('r:fareInfoGroup/r:fareAmount/r:otherMonetaryDetails[r:typeQualifier="E"][r:currency="RUB"]/r:amount|
          r:fareInfoGroup/r:fareAmount/r:monetaryDetails[r:typeQualifier="B"][r:currency="RUB"]/r:amount').to_f * passengers_in_group
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
          price_fare = pricing_group.xpath('r:fareInfoGroup/r:fareAmount/r:otherMonetaryDetails[r:typeQualifier="E"][r:currency="RUB"]/r:amount|
          r:fareInfoGroup/r:fareAmount/r:monetaryDetails[r:typeQualifier="B"][r:currency="RUB"]/r:amount').to_f * passengers_in_group
          price_tax = price_total - price_fare
          [price_fare, price_tax]
      end

      def recommendations rec
        xml_recommendations = xpath("//r:pricingGroupLevelGroup").group_by do |pr|
          pr.xpath("r:passengersID/r:travellerDetails/r:measurementValue").to_s
        end.values
        min_count = xml_recommendations.map(&:count).min
        xml_recommendations = xml_recommendations.each{|values| values[min_count..-1] = []}

        xml_recommendations.transpose.map do |xml_recommendation|
          new_rec = Recommendation.new(:variants => rec.variants)
          new_rec.booking_classes = xml_recommendation.first.xpath('r:fareInfoGroup/r:segmentLevelGroup/r:cabinGroup/r:cabinSegment/r:bookingClassDetails/r:designator').map(&:to_s)
          new_rec.cabins = xml_recommendation.first.xpath('r:fareInfoGroup/r:segmentLevelGroup/r:cabinGroup/r:cabinSegment/r:bookingClassDetails/r:option').map(&:to_s)
          new_rec.price_fare, new_rec.price_tax = xml_recommendation.map{|cg|local_prices cg}.transpose.map{|x| x.reduce(:+)}
          new_rec
        end
      end
    end
  end
end

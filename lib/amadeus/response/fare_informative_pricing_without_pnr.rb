# encoding: utf-8
module Amadeus
  module Response
    class FareInformativePricingWithoutPNR < Amadeus::Response::Base

      # deprecated
      def prices
        return unless success?
        rec = recommendations.first
        [rec.price_fare, rec.price_tax]
      end

      def baggage
        return unless success?
        recommendations.first.baggage_array
      end

      def recommendations original_rec=nil
        xml_recommendations = xpath("//r:pricingGroupLevelGroup").group_by do |pr|
          pr.xpath("r:passengersID/r:travellerDetails/r:measurementValue").map(&:to_s)
        end.values

        variants = original_rec.try(:variants) || []
        xml_recommendations.transpose.map do |xml_recommendation|
          rec = Recommendation.new( :variants => variants )
          rec.booking_classes = xml_recommendation.first.xpath('r:fareInfoGroup/r:segmentLevelGroup/r:cabinGroup/r:cabinSegment/r:bookingClassDetails/r:designator').map(&:to_s)
          rec.fare_bases = xml_recommendation.first.xpath('r:fareInfoGroup/r:segmentLevelGroup/r:fareBasis/r:additionalFareDetails/r:rateClass').map(&:to_s)
          rec.published_fare = xml_recommendation.first.xpath('r:fareInfoGroup/r:pricingIndicators/r:priceTariffType').to_s == 'I'
          rec.cabins = xml_recommendation.first.xpath('r:fareInfoGroup/r:segmentLevelGroup/r:cabinGroup/r:cabinSegment/r:bookingClassDetails/r:option').map(&:to_s)
          rec.price_fare, rec.price_tax = xml_recommendation.map{|cg|local_prices cg}.transpose.map(&:sum)
          rec.baggage_array = baggage_array(xml_recommendation)
          rec
        end
      end

      def error_message
        xpath('//r:errorGroup/r:errorMessage/r:freeText').to_s.try(:strip)
      end

      def baggage_array(xml_recommendation)
        xml_recommendation.map{|xr| baggage_array_for_group(xr)}.transpose.every.flatten
      end

      def baggage_array_for_group pricing_group
        passengers_in_group = pricing_group.xpath('r:numberOfPax/r:segmentControlDetails/r:numberOfUnits').to_i
        pricing_group.xpath('r:fareInfoGroup/r:segmentLevelGroup/r:baggageAllowance/r:baggageDetails').map do |bd|
          [BaggageLimit.new(quantity_code: bd.xpath('r:quantityCode').to_s,
            free_allowance: bd.xpath('r:freeAllowance').to_i)
          ] * passengers_in_group
        end
      end

    private

      def local_prices pricing_group
        passengers_in_group = pricing_group.xpath('r:numberOfPax/r:segmentControlDetails/r:numberOfUnits').to_i
          price_total = pricing_group.xpath('r:fareInfoGroup/r:fareAmount/r:otherMonetaryDetails[r:typeQualifier="712"][r:currency="RUB"]/r:amount').to_f * passengers_in_group
          price_fare = pricing_group.xpath('r:fareInfoGroup/r:fareAmount/r:otherMonetaryDetails[r:typeQualifier="E"][r:currency="RUB"]/r:amount|
          r:fareInfoGroup/r:fareAmount/r:monetaryDetails[r:typeQualifier="B"][r:currency="RUB"]/r:amount').to_f * passengers_in_group
          price_tax = price_total - price_fare
          [price_fare, price_tax]
      end

    end
  end
end

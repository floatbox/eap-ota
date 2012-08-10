# encoding: utf-8
module Amadeus
  module Response
    module BaggageInfo

      def baggage_with_refs
        @baggage_with_refs ||= xpath('//r:fareList/r:segmentInformation/r:bagAllowanceInformation/r:bagAllowanceDetails').inject({}) do |memo, bi|
          baggage_quantity = bi.xpath('r:baggageQuantity').to_i
          baggage_weight = bi.xpath('r:baggageWeight').to_i
          baggage_type = bi.xpath('r:baggageType').to_s
          measure_unit = bi.xpath('r:measureUnit').to_s
          segment_ref = bi.xpath('../../r:segmentReference/r:refDetails/r:refNumber').to_i
          passenger_refs = bi.xpath('../../../r:paxSegReference/r:refDetails/r:refNumber').every.to_i
          infant_flag = bi.xpath('../../../r:statusInformation/r:firstStatusDetails[r:tstFlag="INF"]').present? ? 'i' : 'a'
          passenger_refs.each do |pax_ref|
              memo[[pax_ref, infant_flag]] ||= {}
              memo[[pax_ref, infant_flag]][segment_ref] = BaggageLimit.new(:baggage_quantity => baggage_quantity, :baggage_type => baggage_type, :baggage_weight => baggage_weight, :measure_unit => measure_unit)
          end
          memo
        end
      end

      def baggage_for_segments
        @baggage_for_segments ||= baggage_with_refs.find{|k, v| k[1] == 'a'}[1]
      end

      def coded_baggage_for_persons
        @coded_baggage_for_persons ||= Hash[baggage_with_refs.map do |pax_ref, segment_ref|
          [pax_ref,
           segment_ref.sort_by{|k,v| k}.map{|k,v| v.serialize}.join(' ')]
        end]
      end
    end
  end
end


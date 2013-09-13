# encoding: utf-8
module Amadeus
  module Response
    class FareCheckRules < Amadeus::Response::Base
      def rules
        xpath('//r:flightDetails').inject({}) do |result, fd|
          marketing_carrier = fd.xpath('r:transportService/r:companyIdentification/r:marketingCompany').to_s
          fare_base = fd.xpath('r:qualificationFareDetails/r:additionalFareDetails/r:fareClass').to_s
          from = fd.xpath('r:odiGrp/r:originDestination/r:origin').to_s
          to = fd.xpath('r:odiGrp/r:originDestination/r:destination').to_s
          passenger_type = fd.xpath('r:qualificationFareDetails/r:fareDetails/r:qualifier').to_s
          rule_section_id = fd.xpath('r:travellerGrp/r:fareRulesDetails/r:ruleSectionId').to_s
          result[[marketing_carrier, fare_base, Location[from], Location[to], passenger_type]] ||= xpath("//r:tariffInfo[r:fareRuleInfo/r:ruleSectionLocalId='#{rule_section_id}']/r:fareRuleText/r:freeText").map{|t| t.to_s.to_s}.join("\n")
          result
        end
      end
    end
  end
end


# encoding: utf-8
module Amadeus
  module Response
    class FareCheckRules < Amadeus::Response::Base
      def rules
        xpath('//r:tariffInfo').map do |ti|
          (ti / 'r:fareRuleText/r:freeText').map{|t| t.to_s.to_s}.join("\n")
        end
      end
    end
  end
end
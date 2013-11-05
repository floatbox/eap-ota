# encoding: utf-8
module Amadeus
  module Response
    class TicketCreateTSTFromPricing < Amadeus::Response::Base
      def success?
        xpath('//r:tstList').present?
      end

      def error_message
        xpath('//r:errorText/r:errorFreeText').to_s
      end
    end
  end
end

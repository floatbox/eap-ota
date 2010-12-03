module Amadeus
  module Response
    class TicketCreateTSTFromPricing < Amadeus::Response::Base
      def success?
        xpath('r:tstList').present?
      end

      def message
        xpath('r:errorText/r:errorFreeText').to_s
      end
    end
  end
end

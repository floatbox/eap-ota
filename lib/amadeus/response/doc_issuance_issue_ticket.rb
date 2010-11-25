module Amadeus
  module Response
    class DocIssuanceIssueTicket < Amadeus::Response::Base
      def success?
        xpath('r:processingStatus/r:statusCode').to_s == 'O'
      end

      def message
        xpath('r:errorGroup/r:errorWarningDescription/r:freeText').to_s.strip
      end
    end
  end
end

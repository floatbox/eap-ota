# encoding: utf-8
module Amadeus
  module Response
    class DocIssuanceIssueTicket < Amadeus::Response::Base
      def success?
        xpath('r:processingStatus/r:statusCode').to_s == 'O'
      end

      def error_message
        xpath('r:errorGroup/r:errorWarningDescription/r:freeText').to_s.try(:strip)
      end
    end
  end
end

module Alfastrah
  module Confirmation
    class Response
      def initialize response_xml
        @data = ActiveSupport::XmlMini.parse response_xml
      end

      def series
        @data['Envelope']['Body']['confirmPolicyResult']['series']['__content__']
      end

      def number
        @data['Envelope']['Body']['confirmPolicyResult']['fullNumber']['__content__']
      end

      def url
        @data['Envelope']['Body']['confirmPolicyResult']['policyDocument']['url']['__content__']
      end
    end
  end
end

module Alfastrah
  module Purchase
    class Response
      def initialize response_xml
        @data = ActiveSupport::XmlMini.parse response_xml
      end

      def policy_id
        @data['Envelope']['Body']['createPolicyResult']['policyId']['__content__']
      end

      def price
        @price ||= begin
          price = @data['Envelope']['Body']['createPolicyResult']['calculationResult']['premium']['__content__']
          price.to_f
        end
      end

      def currency
        @data['Envelope']['Body']['createPolicyResult']['calculationResult']['currency']['__content__']
      end
    end
  end
end

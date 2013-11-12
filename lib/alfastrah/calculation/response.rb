module Alfastrah
  module Calculation
    class Response
      def initialize response_xml
        @data = ActiveSupport::XmlMini.parse response_xml
      end

      def price
        @price ||= begin
          price = @data['Envelope']['Body']['calculatePolicyResult']['calculationResult']['premium']['__content__']
          price.to_f
        end
      end

      def currency
        @data['Envelope']['Body']['calculatePolicyResult']['calculationResult']['currency']['__content__']
      end
    end
  end
end

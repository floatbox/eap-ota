class Alfastrah
  module Calculation
    class Response < Alfastrah::Base::Response
      JSON_FIELDS = %w[price currency]

      def price
        @price ||= begin
          price = base_path['calculationResult']['premium']['__content__']
          price.to_f
        end
      end

      def currency
        base_path['calculationResult']['currency']['__content__']
      end

      private

      def base_path
        @data['Envelope']['Body']['calculatePolicyResult']
      end
    end
  end
end

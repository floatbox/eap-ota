class Alfastrah
  module Purchase
    class Response < Alfastrah::Base::Response
      JSON_FIELDS = %w[policy_id price currency]
      def policy_id
        base_path['policyId']['__content__']
      end

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
        @data['Envelope']['Body']['createPolicyResult']
      end
    end
  end
end

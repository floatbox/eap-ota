class Alfastrah
  module Info
    class Response < Alfastrah::Base::Response
      def status
        price = base_path['policyInformation']['policyStatus']['__content__']
      end

      def rate
        base_path['policyInformation']['rate']['__content__'].to_f
      end

      private

      def base_path
        @data['Envelope']['Body']['getPolicyResult']
      end
    end
  end
end

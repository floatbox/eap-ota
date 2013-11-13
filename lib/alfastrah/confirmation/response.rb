class Alfastrah
  module Confirmation
    class Response < Alfastrah::Base::Response
      def series
        base_path['series']['__content__']
      end

      def number
        base_path['fullNumber']['__content__']
      end

      def url
        base_path['policyDocument']['url']['__content__']
      end

      private

      def base_path
        @data['Envelope']['Body']['confirmPolicyResult']
      end
    end
  end
end

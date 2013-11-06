module Amadeus
  module Request
    class PNRRetrieve < Amadeus::Request::Base
      attr_accessor :number

      def summary
        number
      end

    end
  end
end

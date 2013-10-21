module Amadeus
  module Request
    class PNRCancel  < Amadeus::Request::Base
      attr_accessor :number

      def summary
        number
      end
    end
  end
end


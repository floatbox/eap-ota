module Amadeus
  module Response
    class PNRAddMultiElements < Amadeus::Response::Base
      def pnr_number
        xpath('//r:controlNumber').to_s
      end

      def error_text
        xpath('//r:messageErrorText/r:text').every.to_s.join(', ')
      end
    end
  end
end

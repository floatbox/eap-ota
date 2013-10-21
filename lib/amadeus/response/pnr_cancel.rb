# encoding: utf-8
module Amadeus
  module Response
    class PNRCancel < PNRRetrieve

      def error_message
        xpath('//r:messageErrorText/r:text').every.to_s.join(', ')
      end
    end
  end
end


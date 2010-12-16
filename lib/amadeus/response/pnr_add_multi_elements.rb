module Amadeus
  module Response
    class PNRAddMultiElements < PNRRetrieve
      def pnr_number
        xpath('//r:controlNumber').to_s
      end

      def error_text
        xpath('//r:messageErrorText/r:text').every.to_s.join(', ')
      end

      def message
        # учитывать только ошибки, в дальнейшем?
        error_text
      end

      def success?
        xpath('//r:generalErrorInfo/r:messageErrorInformation/r:errorDetail[r:qualifier="EC"]').empty?
      end
    end
  end
end

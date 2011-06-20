# encoding: utf-8
module Amadeus
  module Response
    class PNRAddMultiElements < PNRRetrieve
      def pnr_number
        xpath('//r:controlNumber').to_s
      end

      def error_text
        xpath('//r:messageErrorText/r:text').every.to_s.join(', ')
      end

      def error_message
        # тут и warnings тоже, скорее всего. учитывать только ошибки, в дальнейшем?
        error_text
      end

      def success?
        xpath('//r:generalErrorInfo/r:messageErrorInformation/r:errorDetail[r:qualifier="EC"]').empty? &&
          xpath('//r:nameError/r:nameErrorInformation/r:errorDetail[r:qualifier="EC"]').empty?
      end
    end
  end
end


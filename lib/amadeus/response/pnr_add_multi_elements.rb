# encoding: utf-8
module Amadeus
  module Response
    class PNRAddMultiElements < PNRRetrieve

      def error_text
        (xpath('//r:messageErrorText/r:text').every.to_s + srfoid_errors).join(', ')
      end

      def error_message
        # тут и warnings тоже, скорее всего. учитывать только ошибки, в дальнейшем?
        error_text
      end

      def srfoid_errors
        xpath('//r:dataElementsIndiv[r:elementManagementData/r:status="ERR"][r:serviceRequest/r:ssr/r:type="FOID"]/r:elementErrorInformation/r:elementErrorText/r:text').map do |error_text_element|
          "SRFOID error: #{validating_carrier_code}: #{error_text_element.to_s.strip}"
        end.uniq
      end

      def success?
        xpath('//r:generalErrorInfo/r:messageErrorInformation/r:errorDetail[r:qualifier="EC"]').empty? &&
          xpath('//r:nameError/r:nameErrorInformation/r:errorDetail[r:qualifier="EC"]').empty? &&
          xpath('//r:dataElementsIndiv[r:elementManagementData/r:status="ERR"]').empty?
      end
    end
  end
end


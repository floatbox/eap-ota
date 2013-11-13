module Alfastrah
  module Base
    class Response
      def initialize response_xml
        @data = ActiveSupport::XmlMini.parse response_xml
      end

      def ok?
        base_path['returnCode']['code']['__content__'] == 'OK'
      end

      def errors
        base_path['returnCode']['errorMessage']['__content__'] unless ok?
      end

      private

      def base_path
        raise NotImplementedError
      end
    end
  end
end

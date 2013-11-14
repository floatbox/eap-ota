class Alfastrah
  module Base
    class Response
      def initialize response_xml
        @data = ActiveSupport::XmlMini.parse response_xml
      end

      def success?
        base_path['returnCode']['code']['__content__'] == 'OK'
      end

      def errors
        base_path['returnCode']['errorMessage']['__content__'] unless success?
      end

      def as_json options = {}
        json_fields.inject({}) do |hsh, field|
          hsh[field] = send field
          hsh
        end
      end

      def json_fields
        self.class.const_get 'JSON_FIELDS'
      end

      private

      def base_path
        raise NotImplementedError
      end
    end
  end
end

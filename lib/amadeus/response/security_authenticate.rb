# encoding: utf-8
module Amadeus
  module Response
    class SecurityAuthenticate < Base
      def success?
        xpath('//r:statusCode').to_s == 'P'
      end

      def session_id
        xpath('//header:SessionId').to_s
      end
    end
  end
end

# encoding: utf-8
module Amadeus
  module Response
    class SecuritySignOut < Base
      def success?
        xpath('//r:statusCode').to_s == 'P'
      end
    end
  end
end

# encoding: utf-8
module Amadeus
  module Request
    class SecurityAuthenticate < Amadeus::Request::Base
      attr_accessor :office

      def needs_session?
        false
      end

      def organization_id
        case office[0,3]
        when 'MOW'
          'NMC-RUSSIA'
        when 'NYC'
          'NMC-US'
        else
          raise "Please define organization_id for office id #{office}"
        end
      end

    end
  end
end

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
        when 'IEV'
          'NMC-UKRAIN'
        else
          raise "Please define organization_id for office id #{office}"
        end
      end

      # пока лишь бы работало
      def password
        case office
        when 'IEVU228GZ'
          'QU1BREVVUw=='
        else
          'TUk4Vlg4N00='
        end
      end

      # TODO посчитать самим? видимо, длина после base64-декодирования
      def password_length
        case office
        when 'IEVU228GZ'
          7
        else
          8
        end
      end

    end
  end
end

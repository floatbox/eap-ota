# encoding: utf-8
module Amadeus
  module Request
    class SecurityAuthenticate < Amadeus::Request::Base
      attr_accessor :office, :organization, :password

      def needs_session?
        false
      end

      def organization_id
        @organization || Conf.amadeus.offices[office]["organization"]
      end

      # Base64.decode64 от того, что в xml
      def password
        @password || Conf.amadeus.offices[office]["password"]
      end

      def password_b64
        Base64.encode64(password).strip
      end

    end
  end
end

# encoding: utf-8
module Amadeus
  module Request
    class SecurityAuthenticate < Amadeus::Request::Base
      attr_accessor :office

      def needs_session?
        false
      end
    end
  end
end

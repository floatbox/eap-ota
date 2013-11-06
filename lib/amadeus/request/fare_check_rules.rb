module Amadeus
  module Request
    class FareCheckRules < Amadeus::Request::Base
      attr_accessor :sections

      def initialize(*)
        @sections = ['PE']
        super
      end
    end
  end
end

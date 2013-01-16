module Sirena
  module Request
    class PNRStatus < Sirena::Request::Base
      attr_accessor :number

      def initialize(number)
        @number = number
      end
    end
  end
end

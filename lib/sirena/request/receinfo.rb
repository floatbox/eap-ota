module Sirena
  module Request
    class Order < Sirena::Request::Base
      attr_accessor :number, :lead_pass

      def initialize(number, lead_pass)
        @number = number
        @lead_pass = lead_pass
      end
    end
  end
end

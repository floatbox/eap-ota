# encoding: utf-8
module Sirena
  module Response
    class PaymentExtAuth < Sirena::Response::Base
      attr_accessor :cost, :curr

      def parse
        @cost = xpath("///cost")[0]
        if @cost
          @curr = @cost.attribute("curr") && @cost.attribute("curr").value
          @cost = @cost.text
        end
      end
    end
  end
end

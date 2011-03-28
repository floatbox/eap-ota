# encoding: utf-8
module Sirena
  module Response
    class PaymentExtAuth < Sirena::Response::Base
      attr_accessor :cost, :curr, :common_status

      def parse
        @cost = xpath("///cost")[0]
        if @cost
          @curr = @cost.attribute("curr") && @cost.attribute("curr").value
          @cost = @cost.text
        end
        @common_status = xpath("///common_status")
        @common_status = @common_status.text if @common_status
      end
    end
  end
end

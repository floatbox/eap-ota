# encoding: utf-8
module Sirena
  module Response
    class PaymentExtAuth < Sirena::Response::Base
      attr_accessor :cost, :curr, :common_status

      def parse
        @cost = at_xpath("//cost")
        if @cost
          @curr = @cost["curr"]
          @cost = @cost.text
        end
        @common_status = xpath("//common_status").text
      end
    end
  end
end

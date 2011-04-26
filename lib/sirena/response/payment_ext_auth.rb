# encoding: utf-8
module Sirena
  module Response
    class PaymentExtAuth < Sirena::Response::Base
      attr_accessor :cost, :curr, :common_status

      def parse
        if cost = at_xpath("//cost")
          @curr = cost["curr"]
          raise "unexpected currency #{@curr}" unless @curr == 'РУБ'
          @cost = cost.text.to_f
        end
        @common_status = xpath("//common_status").text
      end
    end
  end
end

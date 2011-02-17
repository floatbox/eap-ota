# encoding: utf-8
module Sirena
  module Response
    class PaymentExtAuth < Sirena::Response::Base
      def success?
        true
      end
    end
  end
end
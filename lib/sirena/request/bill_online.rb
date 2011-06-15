# encoding: utf-8
module Sirena
  module Request
    class BillOnline < Base
      def query_body
        '<bill_online />'
      end
    end
  end
end

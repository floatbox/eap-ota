# encoding: utf-8
module Sirena
  module Request
    class BillStatic < Base
      def query_body
        '<bill_static />'
      end
    end
  end
end

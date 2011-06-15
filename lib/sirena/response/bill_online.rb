# encoding: utf-8
module Sirena
  module Response
    class BillOnline < Base

      attr_reader :total, :start, :end

      def parse
        @start = at_xpath('//bill_online')['date_start']
        @end = at_xpath('//bill_online')['date_end']
        @total = at_xpath('//total').text.to_i
      end

      def roubles
        total * 0.0252
      end
    end
  end
end

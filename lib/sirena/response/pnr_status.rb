module Sirena
  module Response
    class PNRStatus < Sirena::Response::Base
      attr_accessor :tickets_with_dates

      def parse
        @tickets_with_dates = xpath('//ticket[action[@type="print"]]').inject({}) do |memo, t|
          number = t["num"]
          ticket_date = Date.strptime(t.xpath('action[@type="print"]')[0]['ontime'], '%d.%m.%Y')
          memo.merge({number => ticket_date})
        end

      end
    end
  end
end

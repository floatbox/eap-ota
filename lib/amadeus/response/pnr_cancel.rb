# encoding: utf-8
module Amadeus
  module Response
    # TODO было бы неплохо наследовать он pnr_retrieve или какого-то другого базового класса для pnr_reply
    class PNRCancel < Amadeus::Response::Base

      def error_message
        xpath('//r:messageErrorText/r:text').every.to_s.join(', ')
      end
    end
  end
end


# encoding: utf-8
module Sirena
  module Response
    class PNRHistory < Sirena::Response::Base
      attr_accessor :history

      def initialize(*)
        super
        @history = xpath('//pnr_history').text
      end
    end
  end
end

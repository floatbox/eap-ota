# encoding: utf-8
module Sirena
  module Request
    class ReturnTicket < Sirena::Request::Base
      attr_accessor :pnr_number, :lead_family
      def initialize(pnr_number, lead_family)
        @pnr_number = pnr_number
        @lead_family = lead_family
      end
    end
  end
end


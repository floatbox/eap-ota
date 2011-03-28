# encoding: utf-8
module Sirena
  module Request
    class BookingCancel < Sirena::Request::Base
      attr_accessor :pnr_number, :lead_family
      def initialize(order)
        @pnr_number = order.pnr_number
        @lead_family = order.sirena_lead_pass
      end
    end
  end
end
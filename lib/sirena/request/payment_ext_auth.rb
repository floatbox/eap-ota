# encoding: utf-8
module Sirena
  module Request
    class PaymentExtAuth < Sirena::Request::Base
      attr_accessor :pnr_number, :lead_family, :card, :payment_action, :cost, :curr
      def initialize(action, pnr_number, lead_family, params={})
        @pnr_number = pnr_number
        @lead_family = lead_family
        @cost = params[:cost]
        @curr = 'РУБ'
        @payment_action = action.to_s
      end

      def encrypt?
        true
      end

      def priority
        3
      end
    end
  end
end

# encoding: utf-8
module Sirena
  module Request
    class PaymentExtAuth < Sirena::Request::Base
      attr_accessor :pnr_number, :lead_family, :card, :payment_action, :cost, :curr
      def initialize(order, params={})
        @pnr_number = order.pnr_number
        @lead_family = order.sirena_lead_pass
        @cost = params[:cost]
        @curr = params[:curr]
        @payment_action = params[:action]
#        @card = {
#          :num=>order.card.number,
#          :expire_date=>"01."+order.card.month.to_s+"."+order.card.year_short.to_s,
#          :holder=>order.card.name.to_s,
#          :auth_code=>order.card.number4
#        }
      end
    end
  end
end
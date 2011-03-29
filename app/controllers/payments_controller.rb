# encoding: utf-8
class PaymentsController < ApplicationController

  def edit
    @order = Order.first(:conditions => ["code = ? AND payment_status = 'new'", params[:code]])
    @card = CreditCard.new
  end

  def update
    @order = Order.first(:conditions => ["code = ? AND payment_status = 'new'", params[:code]])
    card = CreditCard.new(params[:card])
    if card.valid?
      payture_response = @order.block_money(card)
      if payture_response.success?
        @order.money_blocked!
        render :text => 'ok'
      elsif payture_response.threeds?
        logger.info "Pay: payment system requested 3D-Secure authorization"
        render :partial => 'booking/threeds', :locals => {:order_id => @order.order_id, :payture_response => payture_response}
      end
    end
  end

end


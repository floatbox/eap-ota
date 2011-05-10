# encoding: utf-8
class PaymentsController < ApplicationController

  def edit
    @order = Order.first(:conditions => ["code = ? AND payment_status = 'not blocked' AND offline_booking = ?", params[:code], true])
    @card = CreditCard.new
  end

  def update
    @order = Order.first(:conditions => ["code = ? AND payment_status = 'not blocked' AND offline_booking = ?", params[:code], true])
    card = CreditCard.new(params[:card])
    if card.valid?
      payture_response = @order.block_money(card)
      if payture_response.success?
        @order.money_blocked!
        render :partial => 'success'
      elsif payture_response.threeds?
        logger.info "Pay: payment system requested 3D-Secure authorization"
        render :partial => 'booking/threeds', :locals => {:order_id => @order.order_id, :payture_response => payture_response}
      else
        logger.info "Pay: payment failed"
        render :partial => 'fail'
      end
    else
      render :json => {:error => 'card[number]'}
    end
  end

end


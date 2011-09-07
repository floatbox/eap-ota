# encoding: utf-8
class PaymentsController < ApplicationController

  before_filter :find_order

  def find_order
    @order = Order.where(["offline_booking = ? and last_pay_time >= ?", true, Time.now]).find_by_code!( params[:code].presence || 'not specified' )
  end

  def edit
    if @order.payment_status == 'not blocked'
      @card = CreditCard.new
    end
  end

  def update
    unless @order.payment_status == 'not blocked'
      render :partial => 'success'
      return
    end

    card = CreditCard.new(params[:card])
    if card.valid?
      payture_response = @order.block_money(card)
      if payture_response.success?
        @order.money_blocked!
        render :partial => 'success'
      elsif payture_response.threeds?
        logger.info "Pay: payment system requested 3D-Secure authorization"
        render :partial => 'booking/threeds', :locals => {:payture_response => payture_response}
      else
        logger.info "Pay: payment failed"
        render :partial => 'fail'
      end
    else
      render :json => {:error => 'card[number]'}
    end
  end

end


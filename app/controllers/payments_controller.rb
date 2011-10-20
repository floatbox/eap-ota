# encoding: utf-8
class PaymentsController < ApplicationController

  before_filter :find_order

  def find_order
    @order = Order.find_by_code!( params[:code].presence )
  end

  def edit
    if @order.last_pay_time <  Date.today || !@order.offline_booking
      render "expired_pay_time", :status => 404
      return
    end

    if @order.payment_status == 'not blocked'
       @card = CreditCard.new
    end
  end

  def update
    if @order.last_pay_time <  Date.today || !@order.offline_booking
      render "expired_pay_time", :status => 404
      return
    end

    unless @order.payment_status == 'not blocked'
      render :partial => 'success'
      return
    end

    card = CreditCard.new(params[:card])
    if card.valid?
      payture_response = @order.block_money(card, nil, request.remote_ip)
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


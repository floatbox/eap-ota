# encoding: utf-8
class PaymentsController < ApplicationController

  before_filter :find_and_check_order

  protected

  def find_and_check_order
    if ( params[:code].blank? ||
        !(@order = Order.find_by_code( params[:code] )) ||
        @order.last_pay_time.nil? ||
        @order.last_pay_time.past? )
      render "expired_pay_time", :status => 404
    end
  end

  public

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


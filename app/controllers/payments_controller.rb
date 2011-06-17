# encoding: utf-8
class PaymentsController < ApplicationController

  def edit
    @order = Order.where(:offline_booking => true).find_by_code!( params[:code].presence || 'not specified' )

    if @order.payment_status == 'not blocked'
      @card = CreditCard.new
    end
  end

  def update
    @order = Order.where(:offline_booking => true).find_by_code!( params[:code].presence || 'not specified' )

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


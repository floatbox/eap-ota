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
      end
    end
  end

end


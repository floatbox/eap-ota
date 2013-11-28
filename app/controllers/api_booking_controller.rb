# encoding: utf-8
class ApiBookingController < ApplicationController
  include BookingEssentials

  skip_before_filter :verify_authenticity_token

  def create
    # FIXME тут должно быть robot: true, но повременю
    @context = Context.new(partner: params[:partner])
    if preliminary_booking_result(false)
      render :json => {
        :success => true,
        :number => @order_form.number,
        :info => @order_form.info_hash
      }
    else
      render :json => {:success => false}
    end
  end

  def update
    # FIXME тут должно быть robot: true, но повременю
    @context = Context.new(partner: params[:partner])
    case pay_result
    when :forbidden_sale, :failed_booking
      render :json => {success: false, reason: 'unable_to_sell'}
    when :new_price
      render :json => {success: false, reason: 'price_changed', info: @order_form.info_hash}
    when :invalid_data
      render :json => {success: false, reason: 'invalid_data', errors: @order_form.errors_hash}
    when :ok
      render :json => {success: true, pnr_number: @order_form.pnr_number}
    when :threeds
      render :json => {:success => 'threeds', :threeds_params => @payment_response.threeds_params, :threeds_url => @payment_response.threeds_url}
    when :failed_payment
      render :json => {success: false, reason: 'payment_error'}
    end

  end

end


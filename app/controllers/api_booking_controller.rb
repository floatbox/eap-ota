# encoding: utf-8
class ApiBookingController < ApplicationController
  include BookingEssentials

  # before_filter :save_partner_cookies, :only => [:preliminary_booking, :api_redirect]

  # вызывается аяксом со страницы api_booking и с морды
  # Parameters:
  #   "query_key"=>"ki1kri",
  #   "recommendation"=>"amadeus.SU.V.M.4.SU2074SVOLCA040512",
  #   "partner"=>"yandex",
  #   "marker"=>"",
  #   "variant_id"=>"1"
  def preliminary_booking

    if Conf.site.forbidden_booking
      respond_to do |format|
        format.json {render :json => {:success => false}}
        format.xml {render 'api/preliminary_booking'}
      end
      return
    end

    @search = PricerForm.new
    @search.adults = params[:adults] if params[:adults]
    @search.children = params[:children] if params[:children]
    @search.infants = params[:infants] if params[:infants]
    recommendation = Recommendation.deserialize(params[:recommendation])
    strategy = Strategy.select( :rec => recommendation, :search => @search )
=begin
    StatCounters.inc %W[enter.preliminary_booking.total]
    StatCounters.inc %W[enter.preliminary_booking.#{partner}.total] if partner

    @destination = get_destination
    StatCounters.d_inc @destination, %W[enter.api.total] if @destination
    StatCounters.d_inc @destination, %W[enter.api.#{partner}.total] if @destination && partner
=end
    unless strategy.check_price_and_availability(false)
      respond_to do |format|
        format.json {render :json => {:success => false}}
        format.xml {render 'api/preliminary_booking'}
      end
    else
      @order_form = OrderForm.new(
        :recommendation => recommendation,
        :people_count => @search.real_people_count,
        :variant_id => params[:variant_id],
        :query_key => @search.query_key,
        :partner => partner,
        :marker => marker
      )
      @order_form.save_to_cache
      respond_to do |format|
        format.json {render :json => {
        :success => true,
        :number => @order_form.number,
        :info => @order_form.info_hash
        }}
        format.xml {render 'api/preliminary_booking'}
      end

      StatCounters.inc %W[enter.preliminary_booking.success]
      StatCounters.inc %W[enter.preliminary_booking.#{partner}.success] if partner
    end
  end

  def pay

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


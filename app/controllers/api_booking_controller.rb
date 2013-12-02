# encoding: utf-8
class ApiBookingController < ApplicationController
  include ContextMethods

  skip_before_filter :verify_authenticity_token
  before_filter :authenticate_partner, :set_context_robot

  def create
    @recommendation = Recommendation.deserialize(params[:recommendation])
    @recommendation.find_commission! context: context
    @search = AviaSearch.new
    @search.adults = params[:adults] if params[:adults]
    @search.children = params[:children] if params[:children]
    @search.infants = params[:infants] if params[:infants]
    @search.segments = @recommendation.segments.map do |s|
      {
        from: s.departure.city.iata,
        to: s.arrival.city.iata,
        date: s.departure_date
      }
    end

    order_flow = OrderFlow.new(search: @search,
                               recommendation: @recommendation,
                               context: context)

    if order_flow.preliminary_booking_result(false)
      @order_form = order_flow.order_form
      render :json => {
        :success => true,
        :order => @order_form.info_hash.merge(
          :id => @order_form.number,
          :link => api_v1_order_url(@order_form.number)
        )
      }
    else
      render :json => {:success => false}
    end
  end

  def update
    @order_form = OrderForm.load_from_cache(params[:id] || params[:order][:number])
    @order_form.context = context
    @order_form.update_attributes(params[:order])
    @order_form.payment.card = params[:card] if params[:card]

    order_flow = OrderFlow.new(order_form: @order_form, context: context, remote_ip: request.remote_ip)

    case order_flow.pay_result
    when :forbidden_sale, :failed_booking
      render :json => {success: false, reason: 'unable_to_sell'}
    when :new_price
      render :json => {success: false, reason: 'price_changed', order: @order_form.info_hash}
    when :invalid_data
      render :json => {success: false, reason: 'invalid_data', order: {errors: @order_form.errors_hash}}
    when :ok
      render :json => {success: true, order: @order_form.info_hash.merge( pnr_number: @order_form.pnr_number ) }
    when :threeds
      payment_response = order_flow.payment_response
      render :json => {:success => 'threeds', :threeds_params => payment_response.threeds_params, :threeds_url => payment_response.threeds_url}
    when :failed_payment
      render :json => {success: false, reason: 'payment_error'}
    end
  end

  private

  def authenticate_partner
    authenticate_or_request_with_http_basic do |token, password|
      if Partner.authenticate(token, password)
        context_builder.partner = token
      end
    end
  end
end


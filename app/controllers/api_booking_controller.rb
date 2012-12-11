# encoding: utf-8
class ApiBookingController < ApplicationController

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
      render :json => {:success => false}
      return
    end

    @search = PricerForm.new
    @search.adults = params[:adults] if params[:adults]
    @search.children = params[:children] if params[:children]
    @search.infants = params[:infants] if params[:infants]
    recommendation = Recommendation.deserialize(params[:recommendation])
    original_booking_classes = recommendation.booking_classes
    strategy = Strategy.select( :rec => recommendation, :search => @search )
=begin
    StatCounters.inc %W[enter.preliminary_booking.total]
    StatCounters.inc %W[enter.preliminary_booking.#{partner}.total] if partner

    @destination = get_destination
    StatCounters.d_inc @destination, %W[enter.api.total] if @destination
    StatCounters.d_inc @destination, %W[enter.api.#{partner}.total] if @destination && partner
=end
    unless strategy.check_price_and_availability
      render :json => {:success => false}
    else
      order_form = OrderForm.new(
        :recommendation => recommendation,
        :people_count => @search.real_people_count,
        :variant_id => params[:variant_id],
        :query_key => @search.query_key,
        :partner => partner,
        :marker => marker
      )
      order_form.save_to_cache
      render :json => {
        :success => true,
        :number => order_form.number,
        :info => order_form.info_hash
        }

      #StatCounters.inc %W[enter.preliminary_booking.success]
      #StatCounters.inc %W[enter.preliminary_booking.#{partner}.success] if partner
    end
  end

=begin
  def recalculate_price
    @order_form = OrderForm.load_from_cache(params[:order][:number])
    @order_form.people_attributes = params[:person_attributes]
    @order_form.valid?
    if @order_form.update_price_and_counts
      render :json => {success: true, info: @order_form.info_hash}
    else
      render :json => {success: false}
    end
  end

  def pay
    if Conf.site.forbidden_sale
      #StatCounters.inc %W[pay.errors.forbidden]
      render :json => {success: false}
      return
    end

    @order_form = OrderForm.load_from_cache(params[:order][:number])
    @order_form.people_attributes = params[:person_attributes]
    @order_form.update_attributes(params[:order])
    @order_form.card = CreditCard.new(params[:card]) if @order_form.payment_type == 'card'

    if @order_form.counts_contradiction
      if @order_form.update_price_and_counts
        render :json => {success: false, info: order_form.info_hash}
      else
        render :json => {success: false}
      end
      return
    end

    if !@order_form.valid?
      StatCounters.inc %W[pay.errors.form]
      logger.info "Pay: invalid order: #{@order_form.errors_hash.inspect}"
      render :json => {:success: false, errors: @order_form.errors_hash}
      return
    end

    strategy = Strategy.select( :rec => @order_form.recommendation, :order_form => @order_form )
    booking_status = strategy.create_booking

    if booking_status == :failed
      StatCounters.inc %W[pay.errors.booking]
      render :json => {success: false}
      return
    elsif booking_status == :price_changed
      render :json => {success: false, info: order_form.info_hash}
      return
    end

    unless @order_form.payment_type == 'card'
      StatCounters.inc %W[pay.success.total pay.success.cash]
      logger.info "Pay: booking successful, payment: cash"
      render :json => {success: true, pnr_number: @order_form.pnr_number}
      return
    end

    custom_fields = PaymentCustomFields.new(
      ip: request.remote_ip,
      order: @order_form.order,
      order_form: @order_form
    )
    payment_response = @order_form.order.block_money(@order_form.card, custom_fields)

    if payment_response.success?
      logger.info "Pay: payment and booking successful"

      unless strategy.delayed_ticketing?
        logger.info "Pay: ticketing"
        unless strategy.ticket
          StatCounters.inc %W[pay.errors.ticketing]
          logger.info "Pay: ticketing failed"
          @order_form.order.unblock!
          render :json => {success: false}
          return
        end
      end
      StatCounters.inc %W[pay.success.total pay.success.card]
      render :json => {success: true, pnr_number: @order_form.pnr_number}
    elsif payment_response.threeds?
      StatCounters.inc %W[pay.3ds.requests]
      logger.info "Pay: payment system requested 3D-Secure authorization"
      #FIXME придумать нормальный ответ
      render :partial => 'threeds', :locals => {:payment => payment_response}

    else # payment_response failed
      strategy.cancel
      StatCounters.inc %W[pay.errors.payment]
      # FIXME ну и почему не сработало?
      logger.info "Pay: payment failed"
      render :json => {success: false}
    end
  ensure
    StatCounters.inc %W[pay.total]
  end

  # Payture: params['PaRes'], params['MD']
  # Payu: params['REFNO'], params['STATUS'] etc.
  # FIXME отработать отмену проведенного Payu платежа, если бронь уже снята
  # FIXME избежать возможности пересмотреть все заказы, возможно этим согрешит
  # неподписанный респонс Payu
  def confirm_3ds
    @payment = Payment.find_3ds_by_backref!(params)

    @order = @payment.order
    if @order.ticket_status == 'canceled'
      logger.info "Pay: booking canceled"
      @error_message = :ticketing
      return
    end

    case @order.payment_status
    when 'not blocked', 'new'
      unless @order.confirm_3ds!(params)
        StatCounters.inc %W[pay.errors.payment pay.errors.3ds pay.errors.3ds_payment]
        logger.info "Pay: problem confirming 3ds"
        @error_message = :payment
      else
        strategy = Strategy.select(:order => @order)

        unless strategy.delayed_ticketing?
          logger.info "Pay: ticketing"

          unless strategy.ticket
            StatCounters.inc %W[pay.errors.ticketing pay.errors.3ds]
            logger.info "Pay: ticketing failed"
            @error_message = :ticketing
            @order.unblock!
          end
        end
      end
    when 'blocked', 'charged'
      # do nothing?
    else
      logger.info "Pay: money unblocked?"
      @error_message = :ticketing
    end
  ensure
    StatCounters.inc %W[pay.total pay.3ds.confirmations]
  end

  def get_destination
    return if !@search.segments
    segment = @search.segments[0]
    return if ([segment.to_as_object.class, segment.from_as_object.class] - [City, Airport]).present? || @search.complex_route?
    to = segment.to_as_object.class == Airport ? segment.to_as_object.city : segment.to_as_object
    from = segment.from_as_object.class == Airport ? segment.from_as_object.city : segment.from_as_object
    Destination.find_or_create_by(:from_iata => from.iata, :to_iata => to.iata , :rt => @search.rt)
  end

  def log_referrer
    if request.referrer && (URI(request.referrer).host != request.host)
      logger.info "Referrer: #{URI(request.referrer).host}"
    end
  # приходят черти откуда.
  rescue # URI::InvalidURIError
    logger.info "Referrer not parsed: #{request.referrer}"
  end
=end
end


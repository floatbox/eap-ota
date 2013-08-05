module BookingEssentials

  def preliminary_booking_result(forbid_class_changing)
    return if Conf.site.forbidden_booking
    @recommendation = Recommendation.deserialize(params[:recommendation])
    @recommendation.find_commission!

    return unless recover_avia_search
    return unless @recommendation.sellable?

    track_partner(params[:partner], params[:marker])
    strategy = Strategy.select( :rec => @recommendation, :search => @search )
    strategy.lax = !!admin_user

    StatCounters.inc %W[enter.preliminary_booking.total]
    StatCounters.inc %W[enter.preliminary_booking.#{partner}.total] if partner
    StatCounters.inc %W[enter.preliminary_booking_by_airline.#{@recommendation.validating_carrier_iata}.total]

    @destination = get_destination
    StatCounters.d_inc @destination, %W[enter.api.total] if @destination
    StatCounters.d_inc @destination, %W[enter.api.#{partner}.total] if @destination && partner

    if strategy.check_price_and_availability(forbid_class_changing)
      @order_form = OrderForm.new(
        :recommendation => @recommendation,
        :people_count => @search.tariffied,
        :variant_id => params[:variant_id],
        :query_key => @coded_search,
        :partner => partner,
        :marker => marker
      )
      @order_form.save_to_cache
      StatCounters.inc %W[enter.preliminary_booking.success]
      StatCounters.inc %W[enter.preliminary_booking.#{partner}.success] if partner
      StatCounters.inc %W[enter.preliminary_booking_by_airline.#{@recommendation.validating_carrier_iata}.success]
      return true
    else
      return
    end
  end

  def recover_avia_search
    if params[:query_key]
      @search = AviaSearch.from_code(params[:query_key])
    else
      @search = AviaSearch.new
      @search.adults = params[:adults] if params[:adults]
      @search.children = params[:children] if params[:children]
      @search.infants = params[:infants] if params[:infants]
      @recommendation.segments.each do |s|
        @search.segments.new(from: s.departure.city.iata, to: s.arrival.city.iata, date: s.departure_date)
      end
    end

  end

  def pay_result
    if Conf.site.forbidden_sale
      StatCounters.inc %W[pay.errors.forbidden]
      return :forbidden_sale
    end
    @order_form = OrderForm.load_from_cache(params[:order][:number])
    @order_form.people_attributes = params[:person_attributes]
    # Среагировать на изменение цены
    @order_form.recommendation.find_commission!
    return :failed_booking unless @order_form.recommendation.sellable?
    @order_form.admin_user = admin_user
    @order_form.update_attributes(params[:order])
    @order_form.card = CreditCard.new(params[:card]) if @order_form.payment_type == 'card'


    if @order_form.counts_contradiction
      StatCounters.inc %W[pay.errors.counts_contradiction]
      if @order_form.update_price_and_counts
        return :new_price
      else
        return :failed_booking
      end
    end

    if @order_form.price_with_payment_commission != @order_form.recommendation.price_with_payment_commission
      @order_form.price_with_payment_commission = @order_form.recommendation.price_with_payment_commission
      @order_form.update_in_cache
      return :new_price
    end
    if !@order_form.valid?
      StatCounters.inc %W[pay.errors.form]
      logger.info "Pay: invalid order: #{@order_form.errors_hash.inspect}"
      return :invalid_data
    end

    strategy = Strategy.select( :rec => @order_form.recommendation, :order_form => @order_form )
    strategy.lax = !!admin_user
    booking_status = strategy.create_booking

    if booking_status == :failed
      StatCounters.inc %W[pay.errors.booking]
      return :failed_booking
    elsif booking_status == :price_changed
      return :new_price
    end

    unless @order_form.payment_type == 'card'
      StatCounters.inc %W[pay.success.total pay.success.cash]
      logger.info "Pay: booking successful, payment: cash"
      return :ok
    end

    custom_fields = PaymentCustomFields.new(
      ip: request.remote_ip,
      order: @order_form.order,
      order_form: @order_form
    )
    @payment_response = @order_form.order.block_money(@order_form.card, custom_fields)

    if @payment_response.success?
      logger.info "Pay: payment and booking successful"

      unless strategy.delayed_ticketing?
        logger.info "Pay: ticketing"
        unless strategy.ticket
          StatCounters.inc %W[pay.errors.ticketing]
          logger.info "Pay: ticketing failed"
          @order_form.order.unblock!
          return :failed_booking
        end
      end
      StatCounters.inc %W[pay.success.total pay.success.card]
      return :ok
    elsif @payment_response.threeds?
      StatCounters.inc %W[pay.3ds.requests]
      logger.info "Pay: payment system requested 3D-Secure authorization"
      return :threeds
    else # payment_response failed
      strategy.cancel
      StatCounters.inc %W[pay.errors.payment]
      # FIXME ну и почему не сработало?
      logger.info "Pay: payment failed"
      return :failed_payment
    end
  ensure
    StatCounters.inc %W[pay.total]
  end

  def get_destination
    return if !@search.segments
    segment = @search.segments[0]
    return if ([segment.to.class, segment.from.class] - [City, Airport]).present? || @search.complex_route?
    to = segment.to.class == Airport ? segment.to.city : segment.to
    from = segment.from.class == Airport ? segment.from.city : segment.from
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
end

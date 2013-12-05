class OrderFlow

  include KeyValueInit
  attr_accessor :context, :marker, :recommendation, :search
  attr_accessor :order_form
  attr_accessor :payment_response
  attr_accessor :remote_ip

  def logger
    Rails.logger
  end

  def preliminary_booking_result(forbid_class_changing)
    return if Conf.site.forbidden_booking

    return unless search
    return unless recommendation.allowed_booking?

    strategy = Strategy.select(rec: recommendation, search: search, context: context)

    StatCounters.inc %W[enter.preliminary_booking.total]
    StatCounters.inc %W[enter.preliminary_booking.#{context.partner_code}.total] unless context.partner.anonymous?
    StatCounters.inc %W[enter.preliminary_booking_by_airline.#{recommendation.validating_carrier_iata}.total]

    if destination = Destination.get_by_search search
      StatCounters.d_inc destination, %W[enter.api.total]
      StatCounters.d_inc destination, %W[enter.api.#{context.partner_code}.total] unless context.partner.anonymous?
    end

    return unless strategy.check_price_and_availability(forbid_class_changing)
    @order_form = OrderForm.new(
      :recommendation => recommendation,
      :people_count => search.tariffied,
      :query_key => search.query_key,
      :partner => context.partner.token,
      :marker => marker
    )
    @order_form.save_to_cache
    StatCounters.inc %W[enter.preliminary_booking.success]
    StatCounters.inc %W[enter.preliminary_booking.#{context.partner_code}.success] unless context.partner.anonymous?
    StatCounters.inc %W[enter.preliminary_booking_by_airline.#{recommendation.validating_carrier_iata}.success]
    return true
  end

  def pay_result
    if Conf.site.forbidden_sale
      StatCounters.inc %W[pay.errors.forbidden]
      return :forbidden_sale
    end
    # Среагировать на изменение цены
    @order_form.recommendation.find_commission!
    return :failed_booking unless @order_form.recommendation.allowed_booking?

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
    if @order_form.invalid?
      StatCounters.inc %W[pay.errors.form]
      logger.info "Pay: invalid order: #{@order_form.errors_hash.inspect}"
      return :invalid_data
    end

    strategy = Strategy.select(
      rec: @order_form.recommendation,
      order_form: @order_form,
      context: context
    )
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
      ip: remote_ip,
      order: @order_form.order,
      order_form: @order_form
    )
    @payment_response = @order_form.order.block_money(@order_form.card, custom_fields)

    if @payment_response.success?
      logger.info "Pay: payment and booking successful"
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

end

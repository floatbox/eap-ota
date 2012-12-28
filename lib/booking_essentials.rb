module BookingEssentials

  def pay_result
    if Conf.site.forbidden_sale
      StatCounters.inc %W[pay.errors.forbidden]
      return :forbidden_sale
    end
    @order_form = OrderForm.load_from_cache(params[:order][:number])
    @order_form.people_attributes = params[:person_attributes]
    @order_form.update_attributes(params[:order])
    @order_form.card = CreditCard.new(params[:card]) if @order_form.payment_type == 'card'

    if @order_form.counts_contradiction
      if @order_form.update_price_and_counts
        return :new_price
      else
        return :failed_booking
      end
    end

    if !@order_form.valid?
      StatCounters.inc %W[pay.errors.form]
      logger.info "Pay: invalid order: #{@order_form.errors_hash.inspect}"
      return :invalid_data
    end

    strategy = Strategy.select( :rec => @order_form.recommendation, :order_form => @order_form )
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
end

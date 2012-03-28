# encoding: utf-8
module Strategy::Sirena::Booking

  def create_booking
    # FIXME обработать ошибку cancel бронирования
    unless TimeChecker.ok_to_sell_sirena(@rec.variants[0].departure_datetime_utc, @rec.last_tkt_date)
      logger.error 'Strategy: time criteria missed'
      dropped_recommendations_logger.info "recommendation: #{@rec.serialize} price_total: #{@rec.price_total} #{Time.now.strftime("%H:%M %d.%m.%Y")}"
      return :failed
    end

    response = sirena.booking(@order_form)

    unless response.success? && response.pnr_number
      sirena.booking_cancel(response.pnr_number, response.lead_family) if response.pnr_number
      logger.error "Strategy::Sirena: booking error: #{response.error}"
      return :failed
    end

    logger.info "Strategy::Sirena: processing booking: #{response.pnr_number}"

    new_rec = @rec.dup_with_new_prices([response.price_fare, response.price_tax])
    unless @order_form.price_with_payment_commission == new_rec.price_with_payment_commission
      logger.error "Strategy::Sirena: price changed on booking: #{@order_form.price_with_payment_commission} -> #{new_rec.price_with_payment_commission}"
      sirena.booking_cancel(response.pnr_number, response.lead_family)
      @order_form.price_with_payment_commission = new_rec.price_with_payment_commission
      @order_form.recommendation = new_rec
      @order_form.update_in_cache
      return :price_changed
    end

    # FIXME просто проверяем возможность добавления
    # sirena.add_remark(response.pnr_number, response.lead_family, '')
    payment_query = sirena.payment_ext_auth(:query, response.pnr_number, response.lead_family)
    unless payment_query.success? && payment_query.cost
      logger.error "Strategy::Sirena: pricing error: #{payment_query.error}"
      # заменить ли на Strategy#cancel?
      sirena.payment_ext_auth(:cancel, response.pnr_number, response.lead_family)
      sirena.booking_cancel(response.pnr_number, response.lead_family)
      return :failed
    end

    unless payment_query.cost == @rec.price_fare + @rec.price_tax
      logger.error "Strategy::Sirena: price changed on payment query: #{@rec.price_fare}, #{@rec.price_tax} -> #{payment_query.cost}"
      sirena.payment_ext_auth(:cancel, response.pnr_number, response.lead_family)
      sirena.booking_cancel(response.pnr_number, response.lead_family)
      return :failed
    end

    @order_form.pnr_number = response.pnr_number
    @order_form.sirena_lead_pass = response.lead_family
    @order_form.save_to_order
    # важно для дальнейшего cancel и ticket
    @order = @order_form.order
    return :success
  end

end

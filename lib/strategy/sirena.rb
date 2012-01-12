# encoding: utf-8
class Strategy::Sirena < Strategy::Base

  def source; 'sirena' end

  attr_writer :sirena
  def sirena
    @sirena ||= Sirena::Service.new
  end

  # preliminary booking
  # ###################
  include Strategy::Sirena::PreliminaryBooking

  # booking
  # #######
  include Strategy::Sirena::Booking

  # canceling
  # ########
  # FIXME обработать ошибки?
  def cancel
    logger.error "Strategy::Sirena: canceling #{@order.pnr_number}"
    sirena.payment_ext_auth(:cancel, @order.pnr_number, @order.sirena_lead_pass)
    sirena.booking_cancel(@order.pnr_number, @order.sirena_lead_pass)
    @order.cancel!
  end

  def void
    logger.error "Strategy::Sirena: voiding #{@order.pnr_number}"
    sirena.return_ticket(@order.pnr_number, @order.sirena_lead_pass)
    #TODO: пометить заказ как войдрованный
  end

  # ticketing
  # #########

  def delayed_ticketing?
    # временная затычка, чтоб 3ds не пытался обилетить "ручное бронирование" и обломаться
    return true if @order.offline_booking?
    false
  end

  def ticket
    payment_confirm = sirena.payment_ext_auth(:confirm, @order.pnr_number, @order.sirena_lead_pass,
                                      :cost => (@order.price_fare + @order.price_tax))
    if payment_confirm.success?
      logger.info "Strategy::Sirena: ticketed succesfully"
      @order.ticket!
      return true
    else
      logger.error "Strategy::Sirena: ticketing error: #{payment_confirm.error}"
      cancel
      return false
    end
  end

  # debug view
  ############

  def raw_pnr
    sirena.pnr_history(:number => @order.pnr_number).history
  end
end


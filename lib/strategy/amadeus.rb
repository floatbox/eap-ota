# encoding: utf-8
class Strategy::Amadeus < Strategy::Base

  def source; 'amadeus' end

  # preliminary booking
  # ###################
  include Strategy::Amadeus::PreliminaryBooking

  # booking
  # #######
  include Strategy::Amadeus::Booking

  # canceling
  # ########
  # FIXME обработать ошибки?

  def cancel
    Amadeus.booking do |amadeus|
      logger.error "Strategy::Amadeus: canceling #{@order.pnr_number}"
      amadeus.pnr_cancel(:number => @order.pnr_number)
      @order.cancel!
    end
  end

  # ticketing
  # #########

  def delayed_ticketing?
    true
  end

  # debug view
  ############

  def raw_pnr
    Amadeus.booking do |amadeus|
      amadeus.pnr_raw(@order.pnr_number)
    end
  end

  def raw_ticket
    Amadeus.booking do |amadeus|
      amadeus.ticket_raw(@ticket.first_number_with_code)
    end
  end

end

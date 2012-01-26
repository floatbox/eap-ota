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
    ::Amadeus.booking do |amadeus|
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
    ::Amadeus.booking do |amadeus|
      amadeus.pnr_raw(@order.pnr_number)
    end
  end

  def raw_ticket
    ::Amadeus.booking do |amadeus|
      amadeus.ticket_raw(@ticket.first_number_with_code)
    end
  end

  def flight_from_gds_code(code)
    return unless m = code.match(/(\w{2})\s?(\d+)\s(\w)\s(\d{2}\w{3})\s\d.(\w{3})(\w{3})/)
    date = Date.strptime(m[4], '%d%h')
    date += 1.year if date < Date.today
    ::Amadeus::Service.air_flight_info(:date => date, :number => m[2], :carrier => m[1], :departure_iata => m[5], :arrival_iata => m[6]).flight
  end

  def booking_attributes
    ::Amadeus.booking do |amadeus|
      pnr_resp = amadeus.pnr_retrieve(:number => @order.pnr_number)
      departure_date = pnr_resp.flights.first.dept_date
      tst_resp = amadeus.ticket_display_tst
      amadeus.pnr_ignore

      if tst_resp.success?
        {
          :departure_date => departure_date,
          :price_fare => tst_resp.total_fare,
          :price_tax => tst_resp.total_tax,
          :commission_carrier => tst_resp.validating_carrier_code,
          :blank_count => tst_resp.blank_count
        }
      else
        { :departure_date => departure_date }
      end

    end
  end

end

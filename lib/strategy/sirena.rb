# encoding: utf-8
class Strategy::Sirena < Strategy::Base

  def source; 'sirena' end

  attr_writer :sirena
  def sirena
    @sirena ||= ::Sirena::Service.new
  end

  # preliminary booking
  # ###################
  include Strategy::Sirena::PreliminaryBooking

  # booking
  # #######
  include Strategy::Sirena::Booking

  # ticketing
  # ##################
  include Strategy::Sirena::Tickets

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

  # debug view
  ############

  def raw_pnr
    sirena.pnr_history(:number => @order.pnr_number).history
  end

  def flight_from_gds_code(code)
    return unless m = code.match(/(\w{2})-(\d+) \w (\d{2}\w{3}\d{2})/)
    date = Date.parse(m[3])
    sirena.raceinfo(:date => date, :flight => m[2], :carrier => m[1]).flight
  end

  def booking_attributes
    order_resp = sirena.order(@order.pnr_number, @order.sirena_lead_pass).or_fail!
    pricing_resp = sirena.pricing_variant(
      :recommendation => order_resp.recommendation,
      :given_passengers => order_resp.passengers
    )

    {
      :departure_date => order_resp.flights.first.dept_date,
      :price_fare => pricing_resp.recommendation.try(:price_fare),
      :price_tax => pricing_resp.recommendation.try(:price_tax)
    }.compact
  end

end

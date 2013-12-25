class OrderFlowLogSubscriber < ActiveSupport::LogSubscriber

  def preliminary_booking_result(event)
    flow = event.payload[:flow]
    partner_code = flow.context.partner_code unless flow.context.partner.anonymous?
    carrier = flow.recommendation.validating_carrier_iata
    StatCounters.inc %W[enter.preliminary_booking.total]
    StatCounters.inc %W[enter.preliminary_booking.#{partner_code}.total] if partner_code
    StatCounters.inc %W[enter.preliminary_booking_by_airline.#{carrier}.total]

    if destination = Destination.get_by_search(flow.search)
      StatCounters.d_inc destination, %W[enter.api.total]
      StatCounters.d_inc destination, %W[enter.api.#{partner_code}.total] if partner_code
    end

    if event.payload[:result]
      StatCounters.inc %W[enter.preliminary_booking.success]
      StatCounters.inc %W[enter.preliminary_booking.#{partner_code}.success] if partner_code
      StatCounters.inc %W[enter.preliminary_booking_by_airline.#{carrier}.success]
    end
  end

  attach_to :order_flow
end


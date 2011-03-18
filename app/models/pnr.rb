# encoding: utf-8
class Pnr
  attr_accessor :number, :flights, :booking_classes, :passengers, :phone, :email, :raw

  def self.get_by_number number
    pnr = self.new
    pnr.number = number
    if pnr.order && pnr.order.source == 'sirena'
      order = Sirena::Service.order(number, pnr.order.sirena_lead_pass)
      pnr.flights = order.flights
      pnr.passengers = order.passengers
      pnr.booking_classes = order.booking_classes
      pnr.phone = order.phone
      pnr.email = order.email
    else
      Amadeus.booking do |amadeus|
        resp = amadeus.pnr_retrieve_and_ignore(:number => number)
        pnr.flights = resp.flights
        pnr.booking_classes = resp.booking_classes
        pnr.passengers = resp.passengers
        pnr.email = resp.email
        pnr.phone = resp.phone

        pnr.raw = amadeus.pnr_raw number
        # FIXME может, надо?
        # amadeus.session.destroy
      end
    end
    pnr
  end

  def order
    @order ||= Order.find_by_pnr_number(number)
  end

  def sirena_receipt
    Sirena::Service.get_itin_receipts(number, order.sirena_lead_pass).pdf
  end

end

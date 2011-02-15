# encoding: utf-8
class Pnr
  attr_accessor :number, :flights, :booking_classes, :passengers, :phone, :email, :raw, :ticket_numbers

  def self.get_by_number number
    pnr = self.new
    pnr.number = number
    Amadeus.booking do |amadeus|
      resp = amadeus.pnr_retrieve_and_ignore(:number => number)
      pnr.flights = resp.flights
      pnr.booking_classes = resp.booking_classes
      pnr.passengers = resp.passengers
      pnr.email = resp.email
      pnr.phone = resp.phone
      pnr.ticket_numbers = resp.ticket_numbers

      pnr.raw = amadeus.pnr_raw number
      # FIXME может, надо?
      # amadeus.session.destroy
      pnr
    end
  end

  def order
    @order || @order = Order.find_by_pnr_number(number)
  end


end

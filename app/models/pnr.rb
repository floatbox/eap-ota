class Pnr
  attr_accessor :number, :flights, :passengers, :phone, :email, :raw, :ticket_number

  def self.get_by_number number
    pnr = self.new
    pnr.number = number
    amadeus = Amadeus::Service.new(:book => true)

    resp = amadeus.pnr_retrieve_and_ignore(:number => number)
    pnr.flights = resp.flights
    pnr.passengers = resp.passengers
    pnr.email = resp.email
    pnr.phone = resp.phone
    pnr.ticket_number = resp.ticket_number

    pnr.raw = amadeus.pnr_raw number
    # FIXME может, надо?
    # amadeus.session.destroy
    pnr
  end


end

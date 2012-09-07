# encoding: utf-8
class PNR
  extend CopyAttrs
  attr_accessor :number, :flights, :booking_classes, :passengers, :phone, :email, :raw, :additional_number

  def self.get_by_number number
    pnr = self.new
    pnr.number = number
    if pnr.order && pnr.order.source == 'sirena'
      order = Sirena::Service.new.order(number, pnr.order.sirena_lead_pass)
      raise Sirena::Error, order.error if order.error
      copy_attrs order, pnr,
        :flights,
        :booking_classes,
        :passengers,
        :phone,
        :email
    else
      Amadeus.booking do |amadeus|
        pnr_resp = amadeus.pnr_retrieve(:number => number)
        copy_attrs pnr_resp, pnr,
          :flights,
          :booking_classes,
          :passengers,
          :phone,
          :email
        add_number = pnr_resp.additional_pnr_numbers[pnr.order.commission_carrier]
        pnr.additional_number = add_number if add_number != pnr.order.pnr_number
        unless pnr.order.sold_tickets.present?
          tst_resp = amadeus.ticket_display_tst
          pnr.flights.each do |fl|
            fl.baggage_limit_for_adult = tst_resp.baggage_for_segments[fl.amadeus_ref]
          end
        end
        amadeus.pnr_ignore
      end
    end
    pnr
  end

  def order
    @order ||= Order.find_by_pnr_number(number)
    raise ActiveRecord::RecordNotFound unless @order
    @order
  end

  def sirena_receipt
    Sirena::Service.new.get_itin_receipts(number, order.sirena_lead_pass).pdf
  end

end


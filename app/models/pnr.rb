# encoding: utf-8
class Pnr
  extend CopyAttrs
  attr_accessor :number, :flights, :booking_classes, :passengers, :phone, :email, :raw

  def self.get_by_number number
    pnr = self.new
    pnr.number = number
    if pnr.order && pnr.order.source == 'sirena'
      order = Sirena::Service.order(number, pnr.order.sirena_lead_pass)
      copy_attrs order, pnr,
        :flights,
        :booking_classes,
        :passengers,
        :phone,
        :email
    else
      Amadeus.booking do |amadeus|
        resp = amadeus.pnr_retrieve_and_ignore(:number => number)
        copy_attrs resp, pnr,
          :flights,
          :booking_classes,
          :passengers,
          :phone,
          :email
      end
    end
    pnr
  end

  def order
    @order ||= Order.find_by_pnr_number(number)
  end

  # для order_show, временное
  # FIXME заменить на #order или убить вообще
  def order_real_or_dummy
    order || Order.new(:source => 'amadeus')
  end

  def sirena_receipt
    Sirena::Service.get_itin_receipts(number, order.sirena_lead_pass).pdf
  end

end

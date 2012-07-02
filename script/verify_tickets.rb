require File.expand_path('../../config/environment',  __FILE__)

def select_orders
  Order.where("ticket_status = ? AND last_pay_time < ? AND payment_type = ?", "booked", Date.tomorrow, "cash").each do |order|
    yield order
  end
end

public
def verify_status
 unless ::Amadeus.booking{|a| a.pnr_retrieve(:number => self.pnr_number).flights_hash.present?}
   self.update_attributes(:ticket_status => 'canceled')
   #puts "#{self.pnr_number} canceled"
 end
end

select_orders(&:verify_status)
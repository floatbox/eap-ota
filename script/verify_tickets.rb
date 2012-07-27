require File.expand_path('../../config/environment',  __FILE__)

def orders
  #использую last_pay_time потому, что он сейчас обновляется руками и актуальней last_tkt_date
  #пустой pnr может быть, в частности, в случае доплаты, которую мы не трогаем
  Order.where("pnr_number != ? AND ticket_status = ? AND last_pay_time < ?", "", "booked", Time.now)
end

def verify_status
  orders.each do |order|
    begin
      response = ::Amadeus.booking{|a| a.pnr_retrieve(:number => order.pnr_number)}
      if response && response.flights_hash.blank?
        order.update_attributes(:ticket_status => 'canceled')
        puts "Amadeus canceled this booking thus we cancel it too: #{order.pnr_number}"
      end
    rescue
      puts "Error: #{$!} pnr number: #{order.pnr_number}"
    end
  end
end
verify_status
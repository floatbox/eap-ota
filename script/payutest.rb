#!/usr/bin/env ruby

require 'pp'
# чтобы не грузить весь environment:
class Rails
  def self.logger; nil; end
end
require_relative '../lib/payu'


require 'logger'
Payu.logger = Logger.new(STDOUT)

payu = Payu.new(
  merchant: 'EVITERRA',
  host: 'sandbox8ru.epayment.ro',
  seller_key: 'w7I2R8~V7=dm5H7[r1k5'
)


order_id = Time.now.strftime('test_%y%m%d_%H%M%S')
response = payu.block 123, nil, :order_id => order_id

if response.success?

#  unblock_response = payu.unblock(:order_id => response.ref)

  charge_response = payu.charge(:order_id => response.ref)

end

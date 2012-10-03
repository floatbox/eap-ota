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

card_as_hash = {:number => '5521756777242815', :type => 'MasterCard', :verification_value => '926', :year => '2014', :month => '04', :name => 'nikolai zaiarnyi'}
order_id = Time.now.strftime('test_%y%m%d_%H%M%S')
response = payu.block 123, card_as_hash, :order_id => order_id
if response.success?
  unblock_response = payu.unblock(:order_id => response.ref)
end

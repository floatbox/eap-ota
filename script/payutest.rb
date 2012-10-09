#!/usr/bin/env ruby -Ilib

require_relative '../config/application'
require 'conf'
require 'pp'
# чтобы не грузить весь environment:
module Rails
  def self.logger; nil; end
end
require 'payu'
require 'active_model'
require 'key_value_init'
require 'credit_card'


require 'logger'
Payu.logger = Logger.new(STDOUT)

payu = Payu.new(
  merchant: 'EVITERRA',
  host: 'sandbox8ru.epayment.ro',
  # host: 'secure.payu.ru',
  # ssl: true,
  seller_key: 'w7I2R8~V7=dm5H7[r1k5'
)

order_id = Time.now.strftime('test_%y%m%d_%H%M%S')

card = Payu.test_card
response = payu.block 123.127, card, :order_id => order_id

#if response.threeds?
#  puts response.threeds_url
#end

#  unblock_response = payu.unblock(:order_id => response.ref)

#  charge_response = payu.charge(:order_id => response.ref)

#  order_id = 'EXT_411349700322'
#  state_response = payu.state(:order_id => order_id)
#  puts state_response.state

#end

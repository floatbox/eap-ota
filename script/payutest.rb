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

our_ref = Time.now.strftime('test_%y%m%d_%H%M%S')
card = Payu.test_card

### BLOCK
  response = payu.block 10, card, :our_ref => our_ref

### STATE
  state_response = payu.state :our_ref => our_ref
  puts state_response.status

### UNBLOCK
#  unblock_response = payu.unblock 5, :their_ref => response.their_ref

### STATE
#  state_response = payu.state(:our_ref => our_ref)
#  puts state_response.status

### CHARGE
  charge_response = payu.charge 10, :their_ref => response.their_ref

### STATE
  state_response = payu.state(:our_ref => our_ref)
  puts state_response.status

### REFUND
  refund_response = payu.refund 5, :their_ref => response.their_ref

### STATE
  state_response = payu.state(:our_ref => our_ref)
  puts state_response.status


#if response.threeds?
#  puts response.threeds_url
#end

#  unblock_response = payu.unblock(:their_ref => response.their_ref)

#  charge_response = payu.charge(:their_ref => response.ref)

#  our_ref = 'EXT_411349700322'
#  state_response = payu.state(:our_ref => our_ref)
#  puts state_response.status

#end

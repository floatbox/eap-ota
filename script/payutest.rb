#!/usr/bin/env ruby -Ilib -Iapp/models

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
require 'payment_custom_fields'


require 'logger'
Payu.logger = Logger.new(STDOUT)

payu = Payu.new(
  merchant: 'EVITERRA',
  host: 'sandbox8ru.epayment.ro',
  # host: 'secure.payu.ru',
  seller_key: 'w7I2R8~V7=dm5H7[r1k5'
)

our_ref = Time.now.strftime('test_%y%m%d_%H%M%S')
card = Payu.test_card
custom_fields = PaymentCustomFields.new(
  :pnr_number => 'ABCDE12',
  :ip => '46.4.115.116',
  :first_name => 'vasya',
  :last_name => 'petrov',
  :email => 'mail@example.com',
  :phone => '79261234567'
)

### BLOCK
  response = payu.block 10, card, :our_ref => our_ref, :custom_fields => custom_fields
  puts response.signed?

### STATE
  status_response = payu.status :our_ref => our_ref
  puts status_response.status

## UNBLOCK
#  unblock_response = payu.unblock :their_ref => response.their_ref, :payment_amount => 10

### STATE
#  status_response = payu.status(:our_ref => our_ref)
#  puts status_response.status

#  exit
### CHARGE
  charge_response = payu.charge :their_ref => response.their_ref, :payment_amount => 10

### STATE
  status_response = payu.status :our_ref => our_ref
  puts status_response.status

### REFUND
  refund_response = payu.refund 3, :their_ref => response.their_ref, :payment_amount => 10

### STATE
  status_response = payu.status :our_ref => our_ref
  puts status_response.status

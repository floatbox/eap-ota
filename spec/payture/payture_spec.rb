require 'spec_helper'

describe Payture do

  use_vcr_cassette 'payture', :record => :new_episodes

  let(:first_order) { "rspec00010" }
  let(:second_order) { "rspec00011" }
  let(:amount) { 100 }
  let(:card) { Payture.test_card }

  it { subject.block(amount, card, :order_id => first_order).should be_success }
  it { subject.unblock(amount, :order_id => first_order).should be_success }

  it { subject.pay(amount, card, :order_id => second_order).should be_success }
  it { subject.refund(amount, :order_id => second_order).should be_success }

end

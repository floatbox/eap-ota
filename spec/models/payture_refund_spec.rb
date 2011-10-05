# encoding: utf-8
require 'spec_helper'

describe PaytureRefund do
  it "should copy ref from payture_charge" do
    order = Order.new
    charge = PaytureCharge.create
    order.payments << charge
    charge.reload!
    refund = charge.refunds.create

    refund.ref.should.should == charge.ref
    refund.order_id.should == charge.order_id
  end
end

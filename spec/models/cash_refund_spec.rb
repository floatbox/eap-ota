# encoding: utf-8
require 'spec_helper'

describe CashRefund do

  it 'should recalculate earnings on save' do
    order = Factory(:order)
    charge = CashCharge.new
    order.payments << charge
    charge.reload
    refund = charge.refunds.create :price => -23.5

    refund.reload
    refund.earnings.should == -23.5
  end

end

# encoding: utf-8
require 'spec_helper'

describe PaytureRefund do
  it "should copy attrs from payture_charge" do
    order = Factory(:order)
    charge = PaytureCharge.new :name_in_card => 'vasya', :pan => '123456xxxxxx1234'
    order.payments << charge
    charge.reload
    refund = charge.refunds.create

    refund.order.should be
    refund.order_id.should == charge.order_id
    refund.ref.should.should == charge.ref
    refund.pan.should == charge.pan
    refund.name_in_card.should == charge.name_in_card
  end

  it "should change sign of refund with positive price" do
    order = Factory(:order)
    charge = PaytureCharge.new :name_in_card => 'vasya', :pan => '123456xxxxxx1234'
    order.payments << charge
    charge.reload
    refund = charge.refunds.create :price => 23.5

    refund.reload
    refund.price.should == -23.5
  end

  it "should not allow to save refund without charge" do
    order = Factory(:order)
    refund = PaytureRefund.new :price => -5, :order => order

    refund.save.should == false
    refund.errors[:charge].should_not be_empty
  end

  pending "should not allow to create refund for more than charged"

  it 'should recalculate earnings on save' do
    order = Factory(:order)
    charge = PaytureCharge.new :name_in_card => 'vasya', :pan => '123456xxxxxx1234'
    order.payments << charge
    charge.reload
    refund = charge.refunds.create :price => -23.5

    refund.reload
    refund.earnings.should == -23.5
  end

end

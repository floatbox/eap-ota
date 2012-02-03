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

  # FIXME кривой тест
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

  describe "state" do
    subject {PaytureRefund.new(:status => current_state)}

    context "blocked" do
      let(:current_state) { 'blocked' }

      its(:can_block?)       { should be_false }
      its(:can_confirm_3ds?) { should be_false }
      its(:can_cancel?)      { should be_true }
      its(:can_charge?)      { should be_true }
    end

    context "charged" do
      let(:current_state) { 'charged' }

      its(:can_block?)       { should be_false }
      its(:can_confirm_3ds?) { should be_false }
      its(:can_cancel?)      { should be_false }
      its(:can_charge?)      { should be_false }
    end

    context "canceled" do
      let(:current_state) { 'canceled' }

      its(:can_block?)       { should be_true }
      its(:can_confirm_3ds?) { should be_false }
      its(:can_cancel?)      { should be_false }
      its(:can_charge?)      { should be_false }
    end
  end

end

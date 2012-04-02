# encoding: utf-8
require 'spec_helper'

describe CashRefund do

  it 'should recalculate earnings on save' do
    order = Factory(:order)
    charge = CashCharge.new :price => 23.5
    order.payments << charge
    charge.reload
    refund = charge.refunds.create :price => -23.5

    refund.reload
    refund.earnings.should == -23.5
  end

  # FIXME кривой тест
  it "should not allow to save refund without charge" do
    order = Factory(:order)
    refund = CashRefund.new :price => -5, :order => order

    refund.should have_errors_on(:charge)
  end

  describe "state" do
    subject {CashRefund.new(:status => current_state)}

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

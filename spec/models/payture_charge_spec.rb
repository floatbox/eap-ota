# encoding: utf-8
require 'spec_helper'

describe PaytureCharge do
  include Commission::Fx

  it 'should recalculate earnings on save' do
    p = PaytureCharge.new :commission => '1.23%', :price => 1000
    p.save!
    p.commission.should == Fx('1.23%')
    p.earnings.should == 1000 - 12.3
  end

  it 'probably should get commission from Conf, if unset' do
    Conf.payture.stub(:commission).and_return('3.45%')
    p = PaytureCharge.new :price => 1000
    p.save!
    p.commission.should == Fx('3.45%')
    p.earnings.should == 1000 - 34.5
  end

  it 'should not allow to update price on charged payment' do
    order = Factory(:order)
    charge = PaytureCharge.new :price => 1000
    order.payments << charge
    charge.update_attribute :status, 'charged'
    charge.reload
    charge.should be_charged

    charge.attributes = {:price => '1050'}
    charge.should have_errors_on(:price)
  end

  it 'should still allow to update price on charged payment if entered price is technically the same' do
    order = Factory(:order)
    charge = PaytureCharge.new :price => 1000
    order.payments << charge
    charge.update_attribute :status, 'charged'
    charge.reload
    charge.should be_charged

    charge.attributes = {:price => '1000'}
    charge.should_not have_errors_on(:price)
  end

  describe "state" do
    subject {PaytureCharge.new(:status => current_state)}

    context "pending" do
      let(:current_state) { 'pending' }

      its(:can_block?)       { should be_true }
      its(:can_confirm_3ds?) { should be_false }
      its(:can_cancel?)      { should be_false }
      its(:can_charge?)      { should be_false }
    end

    context "blocked" do
      let(:current_state) { 'blocked' }

      its(:can_block?)       { should be_false }
      its(:can_confirm_3ds?) { should be_false }
      its(:can_cancel?)      { should be_true }
      its(:can_charge?)      { should be_true }
    end

    context "threeds" do
      let(:current_state) { 'threeds' }

      its(:can_block?)       { should be_false }
      its(:can_confirm_3ds?) { should be_true }
      its(:can_cancel?)      { should be_false }
      its(:can_charge?)      { should be_false }
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

      its(:can_block?)       { should be_false }
      its(:can_confirm_3ds?) { should be_false }
      its(:can_cancel?)      { should be_false }
      its(:can_charge?)      { should be_false }
    end

    context "rejected" do
      let(:current_state) { 'rejected' }

      its(:can_block?)       { should be_false }
      its(:can_confirm_3ds?) { should be_false }
      its(:can_cancel?)      { should be_false }
      its(:can_charge?)      { should be_false }
    end

  end
end

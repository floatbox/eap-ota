# encoding: utf-8
require 'spec_helper'

describe CashCharge do
  include Commission::Fx

  it 'should recalculate earnings on save' do
    p = CashCharge.new :commission => '1.23%', :price => 1000
    p.save!
    p.commission.should == Fx('1.23%')
    p.earnings.should == 1000
  end

  it 'probably should get commission from Conf, if unset' do
    Conf.cash.stub(:commission).and_return('3.45%')
    p = CashCharge.new :price => 1000
    p.save!
    p.commission.should == Fx('3.45%')
    p.earnings.should == 1000
  end

  describe "state" do
    subject {CashCharge.new(:status => current_state)}

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

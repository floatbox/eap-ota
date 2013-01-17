# encoding: utf-8
require 'spec_helper'

describe PaytureCharge do

  before do
    Conf.payture.stub(:commission).and_return('2.85%')
  end

  describe "factories" do
    specify { build(:payture_charge).should be_valid }
    specify { build(:payture_charge, :charged).should be_valid }
    specify { create(:payture_charge, :charged).should be_charged }
    specify { create(:payture_charge, :charged).should_not be_new_record }
  end

  describe "commission" do
    include Commission::Fx

    it 'should recalculate earnings on save' do
      p = PaytureCharge.create! :commission => '1.23%', :price => 1000
      p.commission.should == Fx('1.23%')
      p.earnings.should == 1000 - 12.3
    end

    it 'probably should get commission from Conf, if unset' do
      Conf.payture.stub(:commission).and_return('3.45%')
      p = PaytureCharge.create! :price => 1000
      p.commission.should == Fx('3.45%')
      p.earnings.should == 1000 - 34.5
    end
  end

  it 'should not allow to update price on charged payment' do
    charge = create(:payture_charge, :charged, :price => 1000)
    charge.assign_attributes :price => '1050'
    charge.should have_errors_on(:price)
  end

  it 'should still allow to update price on charged payment if entered price is technically the same' do
    charge = create(:payture_charge, :charged, :price => 1000)
    charge.assign_attributes :price => '1000'
    charge.should be_valid
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

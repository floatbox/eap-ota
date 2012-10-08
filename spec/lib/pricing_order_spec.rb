# encoding: utf-8

require 'spec_helper'

# TODO постабить income_earnings, оттестировать их отдельно
describe Pricing::Order do

  describe '#balance' do
    subject do
      create(:order)
    end
    before do
      create(:payture_charge, :charged, order: subject, price: 2040, commission: '2%')
      create(:cash_charge, :charged, order: subject, price: 1000, commission: '1%')
      ticket = create(:ticket, :aviacenter, order: subject, original_price_fare: 1000, original_price_tax: 100)
      create(:refund, parent: ticket, original_price_fare: 1000, original_price_tax: 100, price_penalty: 100)
    end
    its(:balance) {should == 2899.20}

  end
  pending '#expected_income'
  pending '#expected_earnings'
  pending '#aggregated_income_suppliers'

  before do
    Payture.stub(:pcnt).and_return(0.0285)
  end

  let :base_order_attrs do
    {
      :price_fare => 20000,
      :price_tax => 1000,
      :price_consolidator => 400,
      :price_agent => 2400,
      :price_subagent => 1000,
      :price_blanks => 50,
      :price_discount => 260,
      :price_our_markup => 60
    }
  end

  let :order_attrs do
    {}
  end

  subject do
    Order.new.tap do |o|
      # вызывать какие-то колбэки?
      o.ticket_status = 'ticketed'
      o.payments = payments
      o.save!
      o.assign_attributes base_order_attrs
      o.assign_attributes order_attrs
    end
  end

  context "payture, aviacenter" do
    let :order_attrs do
      {
        :commission_ticketing_method => 'aviacenter'
      }
    end
    let :payments do
      [ PaytureCharge.new(:status => 'blocked', :price => 30000, :commission => '2.85%') ]
    end
    its(:income) {should == 8695 }
    its(:income_earnings) {should == 29145}
    its(:income_suppliers) {should == 20450}
    its(:income_payment_gateways) {should == 855}
  end

  context "payture, direct" do
    let :order_attrs do
      {
        :commission_ticketing_method => 'direct'
      }
    end
    let :payments do
      [ PaytureCharge.new(:status => 'blocked', :price => 30000, :commission => '2.85%') ]
    end
    its(:income) {should == 10545}
    its(:income_earnings) {should == 29145}
    its(:income_suppliers) {should == 18600}
    its(:income_payment_gateways) {should == 855}
  end

  context "cash, aviacenter" do
    let :order_attrs do
      {
        :commission_ticketing_method => 'aviacenter'
      }
    end
    let :payments do
      [ CashCharge.new(:status => 'blocked', :price => 30000, :commission => '2.85%') ]
    end
    its(:income) {should == 9550}
    its(:income_earnings) {should == 30000}
    its(:income_suppliers) {should == 20450}
    its(:income_payment_gateways) {should == 0}
  end

  context "cash, direct" do
    let :order_attrs do
      {
        :commission_ticketing_method => 'direct'
      }
    end
    let :payments do
      [ CashCharge.new(:status => 'blocked', :price => 30000, :commission => '2.85%') ]
    end
    its(:income) {should == 11400}
    its(:income_earnings) {should == 30000}
    its(:income_suppliers) {should == 18600}
    its(:income_payment_gateways) {should == 0}
  end
end

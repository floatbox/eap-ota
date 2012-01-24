# encoding: utf-8

require 'spec_helper'

describe IncomeDistribution do

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
      :price_discount => 200,

      :price_with_payment_commission => 30000
    }
  end

  let :order_attrs do
    {}
  end

  let :order do
    Order.new( base_order_attrs.merge(order_attrs) ).tap do |o|
      # вызывать какие-то колбэки?
    end
  end

  subject {order}

  context "payture, aviacenter" do
    let :order_attrs do
      {
        :commission_ticketing_method => 'aviacenter',
        :payment_type => 'card'
      }
    end
    its(:income) {should == 8695 }
    its(:income_suppliers) {should == 20450}
    its(:income_payment_gateways) {should == 855}
  end

  context "payture, direct" do
    let :order_attrs do
      {
        :commission_ticketing_method => 'direct',
        :payment_type => 'card'
      }
    end
    its(:income) {should == 10545}
    its(:income_suppliers) {should == 18600}
    its(:income_payment_gateways) {should == 855}
  end

  context "cash, aviacenter" do
    let :order_attrs do
      {
        :commission_ticketing_method => 'aviacenter',
        :payment_type => 'cash'
      }
    end
    its(:income) {should == 9550}
    its(:income_suppliers) {should == 20450}
    its(:income_payment_gateways) {should == 0}
  end

  context "cash, direct" do
    let :order_attrs do
      {
        :commission_ticketing_method => 'direct',
        :payment_type => 'cash'
      }
    end
    its(:income) {should == 11400}
    its(:income_suppliers) {should == 18600}
    its(:income_payment_gateways) {should == 0}
  end

end

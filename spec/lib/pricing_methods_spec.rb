# encoding: utf-8

require 'spec_helper'

describe PricingMethods::Order do
  let :base_order_attrs do
    {
      :price_fare => 20000,
      :price_tax => 1000,
      # ticketing_method
      :commission_agent => '12%',
      :commission_subagent => '5%',
      :commission_consolidator => '2%',
      :commission_blanks => 0,
      # commission_our_markup
      :commission_discount => '1%',
      :payment_type => 'card',
      :blank_count => 1
      # commission payment
    }
  end

  let :order_attrs do
    {}
  end

  describe "#recalculation" do
    # делать обычный save?
    let :order do
      Order.new( base_order_attrs.merge(order_attrs) ).tap do |o|
        o.recalculation
        o.calculate_price_with_payment_commission
      end
    end

    subject {order}

    context "base scenario with percentages" do
      its(:price_subagent) {should == 1000}
      its(:price_consolidator) {should == 400}
      its(:price_discount) {should == 200}
      its(:price_with_payment_commission) {should == 21821.92}
    end

    context "with 3 blanks and percentages" do
      let :order_attrs do
        {:blank_count => 3 }
      end

      its(:price_subagent) {should == 1000}
      its(:price_consolidator) {should == 400}
      its(:price_discount) {should == 200}
      its(:price_with_payment_commission) {should == 21821.92}
    end

    context "with 3 blanks and per-ticket commissions" do
      let :order_attrs do
        {
          :blank_count => 3,
          :commission_subagent => 50,
        }
      end

      its(:price_subagent) {should == 150}
      # а тут ничего не меняется
      its(:price_with_payment_commission) {should == 21821.92}
    end

  end

end

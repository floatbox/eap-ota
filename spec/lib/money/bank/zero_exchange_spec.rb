# encoding: utf-8
require 'spec_helper'

describe Money::Bank::ZeroExchange do

  let(:bank) { described_class.new }

  it "should raise error when used on a non zero value" do
    expect {
      Money.new(1, "USD") + Money.new(1, "RUB", bank)
    }.to raise_error(Money::Bank::UnknownRate)
  end

  it "should not raise error when doing arithmetics on a zero value in any currency" do
    (Money.new(1, "USD") + Money.new(0, "RUB", bank)).should == Money.new(1, "USD")
  end
end

# encoding: utf-8
require 'spec_helper'

describe Discount::Rule do

  include Commission::Fx

  describe "#initialize" do
    context "with no params" do
      its(:discount) { should == Fx(0) }
      its(:our_markup) { should == Fx(0) }
    end
  end

  describe "#total=" do
    context "when positive" do
      before {subject.total = Fx("5%")}
      its(:our_markup) {should == Fx("5%")}
      its(:discount) {should == Fx(0)}
    end

    context "when negative" do
      before {subject.total = -Fx("5%")}
      its(:our_markup) {should == Fx(0)}
      its(:discount) {should == Fx("5%")}
    end
  end
end

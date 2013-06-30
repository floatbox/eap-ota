# encoding: utf-8

require 'spec_helper'

describe Commission::Page do
  describe "#empty?" do
    context "when some commissions are defined" do
      before do
        subject.create_rule agent: '...'
        subject.create_rule disabled: true
      end
      it {should_not be_empty}
    end

    context "when no commissions" do
      it {should be_empty}
    end

    context "when every commission is disabled" do
      before do
        subject.create_rule disabled: true
        subject.create_rule not_implemented: "yes"
      end
      it {should be_empty}
    end
  end
end


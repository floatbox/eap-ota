#encoding: utf-8
require 'spec_helper'

describe Variant do
  describe "#flights=" do
    subject do
      Variant.new
    end
    let(:fl1) {Flight.new}
    let(:fl2) {Flight.new}
    let(:fl3) {Flight.new}
    let(:flights) {[fl1,fl2,fl3]}

    before do
      subject.flights = flights
    end

    specify { subject.segments.second.flights.should == [fl2] }
    its('segments.count') { should == flights.size }
    its(:flights) { should == flights }

  end

end

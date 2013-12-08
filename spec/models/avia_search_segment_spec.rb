require 'spec_helper'

describe AviaSearchSegment do
  describe "coercers" do
    it "should eat ISO string" do
      described_class.new(date: '2013-11-09').date.should == Date.new(2013,11,9)
    end

    it "should eat amadeus api string" do
      described_class.new(date: '091113').date.should == Date.new(2013,11,9)
    end

    it "should eat normal date for convenience" do
      described_class.new(date: Date.new(2013,11,9)).date.should == Date.new(2013,11,9)
    end
  end
end

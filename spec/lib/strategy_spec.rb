# encoding: utf-8
require 'spec_helper'
describe Strategy do
  describe "#select" do

    context "for amadeus" do
      let( :object ) { mock('argument', source: 'amadeus') }
      specify { Strategy.select(:source => 'amadeus').should be_a(Amadeus::Strategy) }
      specify { Strategy.select(:order => object).should be_a(Amadeus::Strategy) }
      specify { Strategy.select(:ticket => object).should be_a(Amadeus::Strategy) }
      specify { Strategy.select(:rec => object).should be_a(Amadeus::Strategy) }
    end

    context "for sirena" do
      specify { expect {Strategy.select(:source => 'sirena') }.to raise_error(ArgumentError) }
    end

    context "some bullshit" do
      specify { expect { Strategy.select() }.to raise_error(ArgumentError) }
      specify { expect { Strategy.select(:source => 'foobar') }.to raise_error(ArgumentError) }
    end

  end
end

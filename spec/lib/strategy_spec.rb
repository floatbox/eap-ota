# encoding: utf-8
require 'spec_helper'
describe Strategy do
  describe "#select" do

    context "for amadeus" do
      let( :object ) { mock('argument', source: 'amadeus') }
      specify { Strategy.select(:source => 'amadeus').should be_a(Strategy::Amadeus) }
      specify { Strategy.select(:order => object).should be_a(Strategy::Amadeus) }
      specify { Strategy.select(:ticket => object).should be_a(Strategy::Amadeus) }
      specify { Strategy.select(:rec => object).should be_a(Strategy::Amadeus) }
    end

    context "for sirena" do
      let( :object ) { mock('argument', source: 'sirena') }
      specify { Strategy.select(:source => 'sirena').should be_a(Strategy::Sirena) }
      specify { Strategy.select(:order => object).should be_a(Strategy::Sirena) }
      specify { Strategy.select(:ticket => object).should be_a(Strategy::Sirena) }
      specify { Strategy.select(:rec => object).should be_a(Strategy::Sirena) }
    end

    context "some bullshit" do
      specify { expect { Strategy.select() }.to raise_error(ArgumentError) }
      specify { expect { Strategy.select(:source => 'foobar') }.to raise_error(ArgumentError) }
    end

  end
end

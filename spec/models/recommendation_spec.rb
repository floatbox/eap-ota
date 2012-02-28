# encoding: utf-8
require 'spec_helper'

describe Recommendation do
  it "should deserialize cyrillics" do
    expect { Recommendation.deserialize('sirena.ЮТ.ЦС.YY..ЮТ369ВНКПЛК060711.ЮТ370ПЛКВНК270711') }.to_not raise_error
  end

  describe "#flight=" do
    subject do
      Recommendation.new
    end
    let(:fl1) {Flight.new}
    let(:fl2) {Flight.new}
    let(:fl3) {Flight.new}
    let(:flights) {[fl1,fl2,fl3]}

    before do
      subject.flights = flights
    end

    its(:flights) { should == flights }
    its('variants.size') { should == 1 }

  end

  describe "#example" do
    context "should allow to specify flight details" do

      specify do
        example = Recommendation.example("JFKDME/UN DMEJFK/FV")
        example.flights.first.marketing_carrier_iata.should == 'UN'
        example.flights.last.marketing_carrier_iata.should == 'FV'
      end

      specify do
        example = Recommendation.example("JFKDME/UN:FV DMEJFK/FV")
        example.flights.first.marketing_carrier_iata.should == 'FV'
        example.flights.first.operating_carrier_iata.should == 'UN'
      end

      specify do
        example = Recommendation.example("JFKDME/UN1234 DMEJFK/UN1235")
        example.flights.first.full_flight_number.should == 'UN1234'
        example.flights.last.full_flight_number.should == 'UN1235'
      end

      specify do
        example = Recommendation.example("JFKDME/UN:FV123 DMEJFK/FV")
        example.flights.first.marketing_carrier_iata.should == 'FV'
        example.flights.first.operating_carrier_iata.should == 'UN'
        example.flights.first.full_flight_number.should == 'UN:FV123'
      end
    end
  end
end

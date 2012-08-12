# encoding: utf-8
require 'spec_helper'

describe Flight do
  it "should deserialize cyrillics" do
    expect { Flight.from_flight_code('ЮТ369ВНКПЛК060711') }.to_not raise_error
  end

  context "two identical flights" do
    let(:flights) do
      2.times.collect {
        Flight.new(
          :departure_iata => 'SVO',
          :departure_date => "100812",
          :arrival_iata => 'PLK',
          :arrival_date => "100812",
          :arrival_term => 'D',
          :flight_number => '3335',
          :operating_carrier_iata => 'SU',
          :marketing_carrier_iata => 'AB'
        )
      }
    end

    it "should be identical" do
      flights.uniq.size.should == 1
    end

    it "should be really identical" do
      flights[0].should == flights[1]
    end

  end

  describe "date accessors" do
    specify { Flight.new(:dept_date => Date.today).dept_date.should == Date.today }
    specify { Flight.new(:arrv_date => Date.today).arrv_date.should == Date.today }
  end
end


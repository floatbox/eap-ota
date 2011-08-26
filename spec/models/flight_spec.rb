# encoding: utf-8
require 'spec_helper'

describe Flight do
  it "should deserialize cyrillics" do
    expect { Flight.from_flight_code('ЮТ369ВНКПЛК060711') }.to_not raise_error
  end

  describe "#from_amadeus_code" do
    it "should call air_flight_info with correct params" do
      code = '3  BT 419 Z 01AUG 4 DMERIX HK1  1505 1600  01AUG  E  BT/22BFU3'
      Amadeus::Service.should_receive(:air_flight_info).with(:date => '010812', :number => '419', :carrier => 'BT', :departure_iata => 'DME', :arrival_iata => 'RIX')
      Flight.from_amadeus_code(code)
    end
  end

  describe '#from_short_code' do
    it "should call air_flight_info with correct params" do
      code = 'BT419 010812'
      Amadeus::Service.should_receive(:air_flight_info).with(:date => '010812', :number => '419', :carrier => 'BT')
      Flight.from_short_code(code)
    end
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
end

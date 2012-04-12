# encoding: utf-8
require 'spec_helper'

describe Strategy::Amadeus do
  let (:amadeus) { mock(Amadeus::Service) }

  before do
    # safeguard
    Amadeus.stub(:booking).and_yield(amadeus)
    Amadeus.stub(:ticketing).and_yield(amadeus)
  end

  it "not yet implements #void" do
    expect { described_class.new.void }.to raise_error(NotImplementedError)
  end

  it "not yet implements #ticket" do
    expect { described_class.new.ticket }.to raise_error(NotImplementedError)
  end

  pending "#check_price_and_availability"
  pending "#create_booking"
  pending "#cancel"
  pending "#delayed_ticketing?"
  pending "#raw_pnr"
  pending "#raw_ticket"

  describe "#booking_attributes" do

    before(:each) do
      amadeus.stub(
        pnr_retrieve:
          amadeus_response('spec/amadeus/xml/PNR_Retrieve_with_ticket.xml'),
        ticket_display_tst:
          amadeus_response('spec/amadeus/xml/Ticket_DisplayTST_with_ticket.xml'),
        pnr_ignore: nil
      )
    end

    subject do
      Strategy::Amadeus.new(:order => build(:order)).booking_attributes
    end

    it {should include(:blank_count => 1)}
    it {should include(:commission_carrier => "SU")}
    it {should include(:departure_date => Date.new(2011, 9, 8))}
    it {should include(:price_fare => 1400)}
    it {should include(:price_tax => 1281)}

  end

  describe "#recommendation_from_booking" do

    before(:each) do
      amadeus.stub(
        pnr_retrieve:
          amadeus_response('spec/amadeus/xml/PNR_Retrieve_with_ticket.xml'),
        ticket_display_tst:
          amadeus_response('spec/amadeus/xml/Ticket_DisplayTST_with_ticket.xml'),
        pnr_ignore: nil
      )
    end

    subject do
      Strategy::Amadeus.new(:order => build(:order)).recommendation_from_booking
    end

    its(:validating_carrier_iata) {should == "SU"}
    its(:price_fare) {should == 1400}
    its(:price_tax) {should == 1281}
    its('flights.first.flight_code') {should == ':SU788MRVSVO080911'}

  end

  describe "#flight_from_gds_code" do
    let (:flight) { mock(Flight) }

    it "should call air_flight_info with correct params" do
      code = '3  BT 419 Z 01AUG 4 DMERIX HK1  1505 1600  01AUG  E  BT/22BFU3'
      Amadeus::Service.should_receive(:air_flight_info)\
        .with(:date => Date.new(2012, 8, 1), :number => '419', :carrier => 'BT', :departure_iata => 'DME', :arrival_iata => 'RIX')\
        .and_return( mock(Amadeus::Response::AirFlightInfo, flight: flight) )

      Strategy::Amadeus.new.flight_from_gds_code(code).should == flight
    end
  end

end

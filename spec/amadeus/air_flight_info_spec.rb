# encoding: utf-8
require 'spec_helper'

describe Amadeus::Response::AirFlightInfo do
  describe 'with technical stop' do

    let_once!(:flight_info) { amadeus_response('spec/amadeus/xml/Air_FlightInfo.xml') }

    subject { flight_info.flight }

    its(:arrival_iata) { should == 'CAN' }
    its(:departure_iata) { should == 'SVO' }
    its(:marketing_carrier_iata) { should == 'CZ' }
    its(:operating_carrier_iata) { should == 'SU' }
    its(:departure_term) { should == 'F' }
    its(:arrival_term) { should == '3' }
    its(:flight_number) { should == '6002' }
    its(:arrival_date) { should == '020911' }
    its(:arrival_time) { should == '1425' }
    its(:departure_date) { should == '010911' }
    its(:departure_time) { should == '2240' }
    its(:equipment_type_iata) { should == '752' }
    its(:technical_stop_count) { should == 1 }
    it { should have(1).technical_stops }

    describe "first technical stop" do
      subject { flight_info.flight.technical_stops.first }
      its(:location_iata) { should == 'URC'  }
      its(:arrival_time) { should == '0740'}
      its(:arrival_date) { should == '020911' }
      its(:departure_date) { should == '020911' }
      its(:departure_time) { should == '0945' }
    end
  end

end


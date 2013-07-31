# encoding: utf-8
require 'spec_helper'

describe Sirena::Response::Raceinfo, sirena: true do

  describe "with no errors" do

    let(:xml) { 'spec/sirena/xml/raceinfo.xml' }
    subject_once! { described_class.new( File.read(xml) )}

    it { should be_success }
    its("flight.operating_carrier_iata") { should == "ЮТ" }
    its("flight.marketing_carrier_iata") { should == "ЮТ" }
    its("flight.departure_iata") { should == 'ВНК' }
    its("flight.arrival_iata") { should == 'ПЛК' }
    its("flight.flight_number") { should == '369' }
    its("flight.arrival_time") { should == '1225' }
    its("flight.departure_time") { should == '1105' }
    its('flight.departure_date') { should == '260911' }
    its('flight.arrival_date') { should == '260911' }

  end

end

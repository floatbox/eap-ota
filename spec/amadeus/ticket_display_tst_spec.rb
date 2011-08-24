# encoding: utf-8
require 'spec_helper'

describe Amadeus::Response::TicketDisplayTST do
  describe 'adult with infant' do

    subject {
      body = File.read('spec/amadeus/xml/Ticket_DisplayTST_With_Infant.xml')
      doc = Amadeus::Service.parse_string(body)
      Amadeus::Response::TicketDisplayTST.new(doc)
    }

    it { should be_success }
    specify { subject.prices_with_refs.should have(1).keys }
    specify { subject.prices_with_refs.values[0].should have(4).keys }
    specify { subject.prices_with_refs.values[0].should == {:price_fare=>5985, :price_tax=>656, :price_fare_infant => 600, :price_tax_infant => 171}}
    its(:validating_carrier_code) { should == 'FV' }
  end
end


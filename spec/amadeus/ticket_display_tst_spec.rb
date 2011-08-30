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
    its(:total_fare) { should == 6585 }
    its(:total_tax) { should == 827 }
    its(:validating_carrier_code) { should == 'FV' }
    its(:last_tkt_date) { should == Date.new(2011, 4, 14) }
    its(:fares_count) { should == 2 }
  end
end


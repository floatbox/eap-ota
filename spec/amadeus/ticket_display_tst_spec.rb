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
    specify { subject.prices_with_refs.should have(2).keys }
    specify { subject.prices_with_refs[[[7, 'a'], [1]]].should == {:price_fare => 5985, :price_tax => 656}}
    specify { subject.prices_with_refs[[[7, 'i'], [1]]].should == {:price_fare => 600, :price_tax => 171}}
    its(:total_fare) { should == 6585 }
    its(:total_tax) { should == 827 }
    its(:validating_carrier_code) { should == 'FV' }
    its(:last_tkt_date) { should == Date.new(2011, 4, 14) }
    its(:blank_count) { should == 2 }
  end

  describe 'two adults' do

    subject {
      body = File.read('spec/amadeus/xml/Ticket_DisplayTST_for_two.xml')
      doc = Amadeus::Service.parse_string(body)
      Amadeus::Response::TicketDisplayTST.new(doc)
    }

    it { should be_success }
    specify { subject.prices_with_refs.should have(2).keys }
    specify { subject.prices_with_refs.values[0].should == {:price_fare => 3825, :price_tax => 3905} }
    its(:total_fare) { should == 7650 }
    its(:total_tax) { should == 7810 }
    its(:validating_carrier_code) { should == 'LH' }
    its(:last_tkt_date) { should == Date.new(2011, 8, 31) }
    its(:blank_count) { should == 2 }
  end


  describe 'complex tickets' do
      subject {
        body = File.read('spec/amadeus/xml/Ticket_DisplayTST_complex_tickets.xml')
        doc = Amadeus::Service.parse_string(body)
        Amadeus::Response::TicketDisplayTST.new(doc)
      }
      its('prices_with_refs.keys.length'){should == 4}
      its('prices_with_refs.keys'){should include([[2, 'a'], [5, 6, 7, 8]])}
      its('prices_with_refs.keys'){should include([[1, 'a'], [5, 6, 7, 8]])}
      its('prices_with_refs.keys'){should include([[1, 'a'], [11, 12]])}
      its('prices_with_refs.keys'){should include([[2, 'a'], [11, 12]])}
      specify{subject.prices_with_refs[[[2, 'a'], [5, 6, 7, 8]]][:price_tax].should == 7814}
      specify{subject.prices_with_refs[[[2, 'a'], [5, 6, 7, 8]]][:price_fare].should == 7600}
      its(:blank_count) {should == 4}

  end

  describe 'tst from booking' do

      subject {
        body = File.read('spec/amadeus/xml/Ticket_DisplayTST_without_tickets.xml')
        doc = Amadeus::Service.parse_string(body)
        Amadeus::Response::TicketDisplayTST.new(doc)
      }
    its(:total_fare) { should == 39860}
    its(:total_tax) { should == 15879 }
    its(:blank_count) { should == 3 }
  end

  describe 'with ticketingStatus NO' do

    subject {
      body = File.read('spec/amadeus/xml/Ticket_DisplayTST_with_ticketingStatus_no.xml')
      doc = Amadeus::Service.parse_string(body)
      Amadeus::Response::TicketDisplayTST.new(doc)
    }

    its('prices_with_refs.keys.every.second.flatten.uniq') {should_not include(2)}
    its('prices_with_refs.keys.every.second.flatten.uniq') {should include(1)}
  end
end


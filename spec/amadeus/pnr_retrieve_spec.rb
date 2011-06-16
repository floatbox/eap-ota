# encoding: utf-8
require 'spec_helper'

describe Amadeus::Response::PNRRetrieve do
  describe 'with two adults, children and infant' do

    subject {
      body = File.read('spec/amadeus/xml/PNR_Retrieve_TwoAdultsWithChildren.xml')
      doc = Amadeus::Service.parse_string(body)
      Amadeus::Response::PNRRetrieve.new(doc)
    }

    it { should be_success }
    it { should have(4).passengers }
    specify { subject.passengers.collect(&:ticket).should == %W( 220-2791248713 220-2791248714 220-2791248716 220-2791248715 ) }
    specify { subject.passengers.collect(&:last_name).should == ['MITROFANOV', 'MITROFANOVA', 'MITROFANOVA', 'MITROFANOVA'] }
    specify { subject.passengers.collect(&:first_name).should == ['PAVEL MR', 'VALENTINA MRS', 'MARIA', 'ARINA'] }
    specify { subject.passengers.collect(&:passport).should == ['111116818', '222228156', '333335276', '444442618'] }
    specify { subject.passengers.find_all{|p| p.infant_or_child == 'i'}.length.should == 1 }
    specify {subject.all_segments_available?.should == true}
    its(:email) { should == 'PAVEL@EXAMPLE.COM' }
    its(:phone) { should == '+75557777555' }

  end

  describe 'three passengers, but only two tickets' do

    subject {
      body = File.read('spec/amadeus/xml/PNR_Retrieve_Strange_Ticket_Number.xml')
      doc = Amadeus::Service.parse_string(body)
      Amadeus::Response::PNRRetrieve.new(doc)
    }

    it { should be_success }
    it { should have(3).passengers }
    specify { subject.passengers.collect(&:ticket).should == ['006-2791485245', '006-2791485244', nil]  }

  end

  describe 'with cancelled by airline segments' do
    subject {
      body = File.read('spec/amadeus/xml/PNR_Retrieve_with_cancelled_by_airline_segments.xml')
      doc = Amadeus::Service.parse_string(body)
      Amadeus::Response::PNRRetrieve.new(doc)
    }

    specify {subject.all_segments_available?.should == false}

  end
end


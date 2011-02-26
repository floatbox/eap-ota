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
    it { should have(4).ticket_numbers }
    #its(:ticket_numbers) { should == %W( 220-2791248713 220-2791248714 220-2791248716 220-2791248715 ) }
    specify { subject.passengers.collect(&:last_name).should == ['MITROFANOV', 'MITROFANOVA', 'MITROFANOVA', 'MITROFANOVA'] }
    specify { subject.passengers.collect(&:first_name).should == ['PAVEL MR', 'VALENTINA MRS', 'MARIA', 'ARINA'] }
    specify { subject.passengers.collect(&:passport).should == ['111116818', '222228156', '333335276', '444442618'] }
    its(:email) { should == 'PAVEL@EXAMPLE.COM' }
    its(:phone) { should == '+75557777555' }

  end
end


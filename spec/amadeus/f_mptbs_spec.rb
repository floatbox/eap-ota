# encoding: utf-8
require 'spec_helper'

describe Amadeus::Response::FareMasterPricerTravelBoardSearch do
  describe 'with NO ITINERARY FOUND' do

    subject {
      body = File.read('spec/amadeus/xml/Fare_MasterPricerTravelBoardSearch_NoItineraryFoundError.xml')
      doc = Amadeus::Service.parse_string(body)
      Amadeus::Response::FareMasterPricerTravelBoardSearch.new(doc)
    }

    it { should_not be_success }
    its(:error_message) { should == 'NO ITINERARY FOUND FOR REQUESTED SEGMENT 2' }
    its(:error_code) { should == '931' }
    its(:recommendations) { should be_empty }

  end
end


# encoding: utf-8
require 'spec_helper'

describe Amadeus::Response::FareMasterPricerTravelBoardSearch do
  let_once! :response do
    amadeus_response('spec/amadeus/xml/Fare_MasterPricerTravelBoardSearch_simple_case.xml')
  end

  describe "response" do
    subject { response }
    it { should be_success }
    it { should have(19).recommendations }
    specify {response.recommendations.first.last_tkt_date.should == Date.parse("12JUN12")}
  end
end


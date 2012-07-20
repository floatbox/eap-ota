# encoding: utf-8
require 'spec_helper'

describe Amadeus::Response::FareInformativeBestPricingWithoutPNR do
  context 'check the parser' do
    let_once! :response do
      amadeus_response('spec/amadeus/xml/Fare_InformativeBestPricingWithoutPNR_adults_complex.xml')
    end

    describe "response" do
      subject { response }
      it { should be_success }
      its(:prices) { should  == [4240.0, 4918.0]}
    end
  end
end


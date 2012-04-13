# encoding: utf-8
require 'spec_helper'

describe Amadeus::Response::FareMasterPricerCalendar do
  context 'with avaliability contexts from slice and dice' do

    let_once! :response do
      amadeus_response('spec/amadeus/xml/Fare_MasterPricerCalendar_slice_and_dice.xml')
    end

    describe "response" do
      subject { response }
      it { should be_success }
      it { should have(15).recommendations }
    end

  end
end


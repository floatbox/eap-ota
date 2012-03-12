# encoding: utf-8
require 'spec_helper'

describe Amadeus::Response::FareMasterPricerCalendar do
  context 'with avaliability contexts from slice and dice' do

    let_once! :response do
      body = File.read('spec/amadeus/xml/Fare_MasterPricerCalendar_slice_and_dice.xml')
      doc = Amadeus::Service.parse_string(body)
      Amadeus::Response::FareMasterPricerCalendar.new(doc)
    end

    describe "response" do
      subject { response }
      it { should be_success }
      it { should have(15).recommendations }
    end

  end
end


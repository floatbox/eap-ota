# encoding: utf-8
require 'spec_helper'

describe Amadeus::Response::FarePricePNRWithBookingClass do
  describe 'adult with infant' do

    let_once! :response do
      body = File.read('spec/amadeus/xml/Fare_PricePNRWithBookingClass.xml')
      doc = Amadeus::Service.parse_string(body)
      described_class.new(doc)
    end

    subject { response }

    it { should be_success }
    its(:fares_count) { should == 2 }
    its(:last_tkt_date) { should == Date.new(2011, 2, 23) }
  end
end


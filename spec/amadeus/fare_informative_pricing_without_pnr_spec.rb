# encoding: utf-8
require 'spec_helper'
describe Amadeus::Response::FareInformativePricingWithoutPNR, :amadeus do

  let_once! :recommendation do
    Recommendation.example("MOWPAR PARMOW")
  end

  describe 'how we do not change the old order of things. 1 adult, 1 child, 1 infant, 1 set of recommendations' do
    let_once! :response do
      amadeus_response('spec/amadeus/xml/Fare_InformativePricingWithoutPNR_all_of_human_groups.xml')
    end
    subject {response}

    specify {response.prices.should == [99640, 18086]}

    specify {response.recommendations(recommendation).first.price_fare.should == 99640}
    specify {response.recommendations(recommendation).first.price_tax.should == 18086}

    its('recommendations.first.fare_bases') {should ==  ["YFLEX1RT", "YFLEX1RT", "YFLEX1RT", "YFLEX1RT"]}
    its('recommendations.first.published_fare') {should be_true}
    its('recommendations.first.baggage_array') {should ==  [[BaggageLimit.new(baggage_quantity: 1, baggage_type: 'N')] * 3]*4}
  end

  describe 'how we do change things for the better. 1 adult, 1 child, 4 sets of recommendations per person' do
    let_once! :response do
      amadeus_response('spec/amadeus/xml/Fare_InformativePricingWithoutPNR_lots_of_recommendations.xml')
    end
    subject {response}

    specify {response.prices.should == [64280, 11752]}

    specify {response.recommendations(recommendation).first.price_fare.should == 64280}
    specify {response.recommendations(recommendation).first.price_tax.should == 11752}
    its('recommendations.first.fare_bases') {should ==  ["YRUTH9", "YRUTH9", "YRUTH9", "YRUTH9"]}
    its('recommendations.first.published_fare') {should be_true}
  end

  describe 'how one girl let me down' do
    let_once! :response do
      amadeus_response('spec/amadeus/xml/Fare_InformativePricingWithoutPNR_freeinfant.xml')
    end
    subject {response}

    specify {response.prices.should == [29600.0, 492.0]}

    specify {response.recommendations(recommendation).first.price_fare.should == 29600.0}
    specify {response.recommendations(recommendation).first.price_tax.should == 492.0}
    its('recommendations.first.fare_bases') {should ==  ["KOW"]}
    its('recommendations.first.published_fare') {should be_true}

    its('recommendations.first.baggage_array') {should ==  [[BaggageLimit.new(baggage_weight: 20, baggage_type: 'W', measure_unit: 'K')] * 4 + [BaggageLimit.new(baggage_weight: 10, baggage_type: 'W', measure_unit: 'K')]]}
  end

  describe 'when children priced as adults' do
    let_once! :response do
      amadeus_response('spec/amadeus/xml/Fare_InformativePricingWithoutPNR_ch_as_adt.xml')
    end
    subject {response}

    specify {response.prices.should == [9900.0, 3705.0]}

    specify {response.recommendations(recommendation).should have(1).item}
    specify {response.recommendations(recommendation).first.price_fare.should == 9900.0}
    specify {response.recommendations(recommendation).first.price_tax.should == 3705.0}
    its('recommendations.first.fare_bases') {should ==  ["UOW"]}
    its('recommendations.first.published_fare') {should be_true}
  end

  describe 'no fares returned' do
    let_once! :response do
      amadeus_response('spec/amadeus/xml/Fare_InformativePricingWithoutPNR_no_fares.xml')
    end
    subject {response}

    specify {response.should_not be_success}

  end

  describe 'with nego fare' do

    let_once! :response do
      amadeus_response('spec/amadeus/xml/Fare_InformativePricingWithoutPNR_nego_fare.xml')
    end
    subject {response}

    specify {response.recommendations.first.published_fare.should be_false}
  end
end

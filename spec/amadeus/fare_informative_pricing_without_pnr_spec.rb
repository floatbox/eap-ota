# encoding: utf-8
require 'spec_helper'
describe Amadeus::Response::FareInformativePricingWithoutPNR do

  let_once! :recommendation do
    Recommendation.example("MOWPAR PARMOW")
  end

  describe 'lotz of recommendations for one adult & one child' do
    let_once! :response do
      amadeus_response('spec/amadeus/xml/Fare_InformativePricingWithoutPNR_lots_of_recommendations.xml')
    end

    subject {response}
    specify { subject.recommendations(recommendation).count.should == 4}
    specify { subject.recommendations(recommendation).first.price_fare.should == 146400}
    specify { subject.recommendations(recommendation).first.booking_classes.should == ["Y", "Y", "Y", "Y"]}
  end

  describe 'simple one: 1 adult, 1 infant, 1 child' do
    let_once! :response do
      amadeus_response('spec/amadeus/xml/Fare_InformativePricingWithoutPNR_all_of_human_groups.xml')
    end

    subject {response}
    specify { subject.recommendations(recommendation).count.should == 1}
    specify { subject.recommendations(recommendation).first.price_fare.should == 99640}
    specify { subject.recommendations(recommendation).first.booking_classes.should == ["Y", "Y", "Y", "Y"]}
  end
end
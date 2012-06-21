# encoding: utf-8
require 'spec_helper'
describe Amadeus::Response::FareInformativePricingWithoutPNR do

  let_once! :recommendation do
    Recommendation.example("MOWPAR PARMOW")
  end

  describe 'how we do not change the old order of things. 1 adult, 1 child, 1 infant, 1 set of recommendations' do
    let_once! :response do
      amadeus_response('spec/amadeus/xml/Fare_InformativePricingWithoutPNR_all_of_human_groups.xml')
    end
    subject {response}

    #Sic! They are the same!
    specify {response.prices.should == [99640, 18086]}
    specify {response.recommendations(recommendation).first.price_fare.should == 99640}
    specify {response.recommendations(recommendation).first.price_tax.should == 18086}
  end

  describe 'how we do change things for the better. 1 adult, 1 child, 4 sets of recommendations per person' do
    let_once! :response do
      amadeus_response('spec/amadeus/xml/Fare_InformativePricingWithoutPNR_lots_of_recommendations.xml')
    end
    subject {response}

    #so now we just sum pretty everything. and this is incorrect
    specify {response.prices.should == [557920, 51008]}

    #and these are perfectly believable
    specify {response.recommendations(recommendation).first.price_fare.should == 64280}
    specify {response.recommendations(recommendation).first.price_tax.should == 11752}
  end
end
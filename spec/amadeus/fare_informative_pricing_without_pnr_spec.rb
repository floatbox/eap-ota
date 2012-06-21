# encoding: utf-8
require 'spec_helper'
describe Amadeus::Response::FareInformativePricingWithoutPNR do

  let_once! :recommendation do
    Recommendation.example("MOWPAR PARMOW")
  end

  describe 'how we do not change the old order of things' do
    let_once! :response do
      amadeus_response('spec/amadeus/xml/Fare_InformativePricingWithoutPNR_all_of_human_groups.xml')
    end
    subject {response}

    #Sic! They are the same!
    specify {response.prices.should == [99640, 18086]}
    specify {response.recommendations(recommendation).first.price_fare.should == 99640}
    specify {response.recommendations(recommendation).first.price_tax.should == 18086}
  end
end
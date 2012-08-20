# encoding: utf-8
require 'spec_helper'

describe Amadeus::Response::FarePricePNRWithLowerFares do

  subject do
    amadeus_response 'spec/amadeus/xml/Fare_PricePNRWithLowerFares.xml'
  end

  its(:prices) {should == [375, 2385]}
  its(:new_booking_classes) {should == ['O']}

end

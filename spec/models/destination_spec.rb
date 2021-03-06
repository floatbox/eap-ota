# encoding: utf-8
require 'spec_helper'

describe Destination do
  let(:destination_attributes) do
   {
     "to_iata"=> 'MOW',
     "from_iata"=> 'LIS',
     "rt" =>true,
     "average_price"=> 8629,
     "average_time_delta"=> 16,
     "hot_offers_counter"=> 1
   }
  end

  subject { Destination.new(destination_attributes) }

  its(:rt) {should == true}
end


# encoding: utf-8
require 'spec_helper'

describe Amadeus::Response::AirRetrieveSeatMap do

  describe "response" do
    let_once! :response do
      (amadeus_response('spec/amadeus/xml/Air_RetrieveSeatMap.xml')).seat_map
    end

    it 'parses correct' do
      response.should have(1).segments
      response.segments.first.should have(24).rows
      response.segments.first.departure_date.should == '140812'
      response.segments.first.rows.first.cabin.should == 'Y'
      response.segments.first.rows[2].seats.first.available?.should == true
      response.segments.first.rows.first.seats.first.window?.should == true
      response.segments.first.rows.first.seats.first.aisle?.should == false
    end
  end
end



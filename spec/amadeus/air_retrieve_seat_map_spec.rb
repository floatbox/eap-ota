# encoding: utf-8
require 'spec_helper'

describe Amadeus::Response::AirRetrieveSeatMap do
  describe "correct parsing" do
    let_once! :response do
      (amadeus_response('spec/amadeus/xml/Air_RetrieveSeatMap.xml')).seat_map
    end

    specify { response.should have(1).segments }
    specify { response.segments.first.should have(24).rows }
    specify { response.segments.first.departure_date.should == '140812' }
    specify { response.segments.first.rows["7"].cabin.should == 'Y' }
    specify { response.segments.first.rows["9"].seats["9A"].available?.should be_true }
    specify { response.segments.first.rows["7"].seats["7A"].window?.should be_true }
    specify { response.segments.first.rows["7"].seats["7A"].aisle?.should be_false }
    specify { response.segments.first.columns["A"].window?.should be_true }
    specify { response.segments.first.columns["A"].aisle?.should be_false }
    specify { response.segments.first['7A'].should == response.segments.first.rows["7"].seats["7A"] }
  end
end



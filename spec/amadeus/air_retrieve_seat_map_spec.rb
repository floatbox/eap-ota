# encoding: utf-8
require 'spec_helper'

describe Amadeus::Response::AirRetrieveSeatMap do
  describe "simple parsing" do
    let_once! :seat_map do
      amadeus_response('spec/amadeus/xml/Air_RetrieveSeatMap.xml').seat_map
    end
    subject { seat_map }

    it { should have(1).segments }

    describe "first segment" do
      subject { seat_map.segments.first }

      it { should have(24).rows }
      its(:departure_date) { should == '140812' }
      specify { subject.rows["7"].cabin.should == 'Y' }
      specify { subject.rows["9"].seats["9A"].available?.should be_true }
      specify { subject.rows["7"].seats["7A"].window?.should be_true }
      specify { subject.rows["7"].seats["7A"].aisle?.should be_false }
      specify { subject.columns["A"].window?.should be_true }
      specify { subject.columns["A"].aisle?.should be_false }
      specify { subject['7A'].should == subject.rows["7"].seats["7A"] }
    end
  end

  describe "747-400" do
    let_once! :seat_map do
      amadeus_response('spec/amadeus/xml/Air_RetrieveSeatMap.747-400.xml').seat_map
    end

    subject { seat_map }

    it { should have(1).segments }
    pending { should have(2).cabins }
    pending "should return unoccupied seat on 31E"
    pending { subject.seats['28A'].should be_no_seat }
  end
end



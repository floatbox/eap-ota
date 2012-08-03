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

      its(:departure_date) { should == '140812' }
      specify { subject.cabins.first.rows.count.should == 24 }
      specify { subject.cabins.first.occupation_default.should == 'F' }
      specify { subject.cabins.first.rows["9"].seats["9A"].available?.should be_true }
      specify { subject.cabins.first.rows["7"].seats["7A"].window?.should be_true }
      specify { subject.cabins.first.rows["7"].seats["7A"].aisle?.should be_false }
      specify { subject.cabins.first.columns["A"].window?.should be_true }
      specify { subject.cabins.first.columns["A"].aisle?.should be_false }
      specify { subject['7A'].should == subject.cabins.first.rows["7"].seats["7A"] }
    end
  end

  describe "747-400" do
    let_once! :seat_map do
      amadeus_response('spec/amadeus/xml/Air_RetrieveSeatMap.747-400.xml').seat_map
    end

    subject { seat_map.segments.first }

    it { should have(2).cabins }
    specify { subject['31E'].should be_available }
    specify { subject['31E'].should be_auto_created }
    specify { subject.cabins.first.class.should == "M" }
    pending { subject.seats['28A'].should be_no_seat }
  end

  describe "first class salon" do
    let_once! :seat_map do
      amadeus_response('spec/amadeus/xml/Air_RetrieveSeatMap.first_class.xml').seat_map
    end

    subject { seat_map.segments.first }

    it "should have only two aisles" do
      subject.cabins.first.columns.values.count(&:aisle_to_the_right).should == 2
    end
  end
end



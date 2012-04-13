# encoding: utf-8
require 'spec_helper'

describe Amadeus::Response::AirSellFromRecommendation do

  describe "#date_shift" do
    subject { described_class.allocate }
    specify { subject.send( :shift_date, '010212', '0005', '2345', 0, 0).should == '010212' }
    specify { subject.send( :shift_date, '010212', '2305', '0005', 1, 0).should == '020212' }
    specify { subject.send( :shift_date, '010212', '2305', '0005', 2, 1).should == '030212' }
    specify { subject.send( :shift_date, '010212', '0005', '2345', 1, 1).should == '020212' }
    specify { subject.send( :shift_date, '010212', '0005', '2345', 1, 1).should == '020212' }
    it "should treat long flight without stops as backward date shift (SVO-DNK)" do
              subject.send( :shift_date, '010212', '0005', '2345', 1, 0).should == '310112'
    end
    it "should treat long flight without stops as backward date shift (TYO-HNL)" do
              subject.send( :shift_date, '140312', '0030', '1240', 1, 0).should == '130312'
    end
  end

  describe 'when arrival is "before" departure because of timezones' do

    let_once! :response do
      amadeus_response('spec/amadeus/xml/Air_SellFromRecommendation_back_in_time.xml')
    end

    subject {response}

    it {should be_success }
    its(:segments_confirmed?) { should be_true }
    its(:segments_status_codes) { should == ['OK'] }

    describe "#fill_itinerary!" do
      let :segments do
        [
          Segment.new(
            :flights => [ Flight.new(
              :departure_iata => 'SVO',
              :arrival_iata => 'DNK',
              :marketing_carrier_iata => 'VV',
              :flight_number => '504',
              :departure_date => '010212' # Date.new(2012, 2, 1)
            ) ]
          )
        ]
      end

      before { response.fill_itinerary!(segments) }

      context "first flight" do
        subject { segments.first.flights.first }

        its(:departure_time) {should == '0005'}
        its(:arrival_time) {should == '2345'}
        its(:arrival_date) {should == '310112'} # Date.new(2012, 1, 31)
        its(:equipment_type_iata) {should == 'ER4'}
        its(:departure_term) {should == 'C'}
        its(:arrival_term) {should == nil}
      end

    end

  end

  describe 'with arrival in after tomorrow' do

    let_once! :response do
      amadeus_response('spec/amadeus/xml/Air_SellFromRecommendation_two_days_flight.xml')
    end

    subject {response}

    it {should be_success }
    its(:segments_confirmed?) { should be_true }
    its(:segments_status_codes) { should == ['OK'] }

    describe "#fill_itinerary!" do
      let :segments do
        [
          Segment.new(
            :flights => [ Flight.new(
              :departure_iata => 'EWR',
              :arrival_iata => 'SIN',
              :marketing_carrier_iata => 'CO',
              :flight_number => '99',
              :departure_date => '171111' # Date.new(2012, 11, 17)
            ) ]
          )
        ]
      end

      before { response.fill_itinerary!(segments) }

      context "first flight" do
        subject { segments.first.flights.first }

        its(:departure_time) {should == '1525'}
        its(:arrival_time) {should == '0130'}
        its(:arrival_date) {should == '191111'} # Date.new(2011, 11, 19)
        its(:equipment_type_iata) {should == 'EQV'}
        its(:departure_term) {should == 'C'}
        its(:arrival_term) {should == nil}
        its(:technical_stop_count) {should == 1}
      end

    end

  end

end


# encoding: utf-8
require 'spec_helper'

describe Recommendation do
  it "should deserialize cyrillics" do
    expect { Recommendation.deserialize('sirena.ЮТ.ЦС.YY..ЮТ369ВНКПЛК060711.ЮТ370ПЛКВНК270711') }.to_not raise_error
  end

  describe "#flight=" do
    subject do
      Recommendation.new
    end
    let(:fl1) {Flight.new}
    let(:fl2) {Flight.new}
    let(:fl3) {Flight.new}
    let(:flights) {[fl1,fl2,fl3]}

    before do
      subject.flights = flights
    end

    its(:flights) { should == flights }
    its('variants.size') { should == 1 }

  end

  describe "#example" do
    context "should allow to specify flight details" do

      specify do
        example = Recommendation.example("JFKDME/UN DMEJFK/FV")
        example.flights.first.marketing_carrier_iata.should == 'UN'
        example.flights.last.marketing_carrier_iata.should == 'FV'
      end

      specify do
        example = Recommendation.example("JFKDME/UN:FV DMEJFK/FV")
        example.flights.first.marketing_carrier_iata.should == 'FV'
        example.flights.first.operating_carrier_iata.should == 'UN'
      end

      specify do
        example = Recommendation.example("JFKDME/UN1234 DMEJFK/UN1235")
        example.flights.first.full_flight_number.should == 'UN1234'
        example.flights.last.full_flight_number.should == 'UN1235'
      end

      specify do
        example = Recommendation.example("JFKDME/UN:FV123 DMEJFK/FV")
        example.flights.first.marketing_carrier_iata.should == 'FV'
        example.flights.first.operating_carrier_iata.should == 'UN'
        example.flights.first.full_flight_number.should == 'UN:FV123'
      end
    end
  end

  describe "class methods" do
    pending ".remove_unprofitable!"
  end

  describe '#income' do

    subject do
      Recommendation.new(
        :price_fare => 10_000,
        :price_tax => 5000,
        :blank_count => 2
      )
    end

    before do
      subject.stub(:commission => commission)
    end

    context "no commission" do
      let(:commission) {nil}
      its(:income) {should == 0}
    end

    context "with all the prices and direct commission" do
      let :commission do
        Commission.new(
          :agent => '4%',
          :subagent => '1%',
          :our_markup => '20',
          :discount => '3%',
          :consolidator => '0',
          :blanks => '0',
          :ticketing_method => 'direct'
        )
      end
      its(:income) {should == 140}
    end

    context "with all the prices and aviacenter commission" do
      let :commission do
        Commission.new(
          :agent => '4%',
          :subagent => '1%',
          :our_markup => '20',
          :discount => '1%',
          :consolidator => '2%',
          :blanks => '0',
          :ticketing_method => 'aviacenter'
        )
      end
      its(:income) {should == 40}
    end

  end

  describe "interline:" do

    let (:not_interline) {Recommendation.example('SVOCDG/SU', :carrier => 'SU')}
    let (:half_interline) {Recommendation.example('SVOCDG/AB CDGSVO/SU', :carrier => 'SU')}
    let (:interline_but_first) {Recommendation.example('SVOCDG/SU CDGSVO/AB', :carrier => 'SU')}
    let (:interline) {Recommendation.example('SVOCDG/AB CDGSVO/AB', :carrier => 'SU')}

    it "#validating_carrier_participates?" do
      not_interline.validating_carrier_participates?.should be_true
      half_interline.validating_carrier_participates?.should be_true
      interline_but_first.validating_carrier_participates?.should be_true
      interline.validating_carrier_participates?.should be_false
    end

    it "#validating_carrier_makes_half_of_itinerary?" do
      not_interline.validating_carrier_makes_half_of_itinerary?.should be_true
      half_interline.validating_carrier_makes_half_of_itinerary?.should be_true
      interline_but_first.validating_carrier_makes_half_of_itinerary?.should be_true
      interline.validating_carrier_makes_half_of_itinerary?.should be_false
    end

    it "#validating_carrier_starts_itinerary?" do
      not_interline.validating_carrier_starts_itinerary?.should be_true
      half_interline.validating_carrier_starts_itinerary?.should be_false
      interline_but_first.validating_carrier_starts_itinerary?.should be_true
      interline.validating_carrier_starts_itinerary?.should be_false
    end

    it "#interline?" do
      not_interline.interline?.should be_false
      half_interline.interline?.should be_true
      interline_but_first.interline?.should be_true
      interline.interline?.should be_true
    end

  end
end

# encoding: utf-8
require 'spec_helper'

describe Recommendation do

  describe "#deserialize" do

    context "recommendation code" do
      subject { Recommendation.deserialize('amadeus.AZ.10772.OOOO.MMMM.3997.SU:AZ7181SVOVCE120113-AF:AZ7328VCECDG120113.AF:AZ7315CDGBLQ120213-SU:AZ7168BLQSVO120213') }
      its(:declared_price){should == 10772}
      its(:booking_classes){should == ['O', 'O', 'O', 'O']}
      its('segments.count'){should == 2}
      its(:subsource) {should be_nil}

    end

    context "with subsource" do
      subject { Recommendation.deserialize('amadeus-MOWR2233B.AZ.10772.OOOO.MMMM.3997.SU:AZ7181SVOVCE120113-AF:AZ7328VCECDG120113.AF:AZ7315CDGBLQ120213-SU:AZ7168BLQSVO120213') }
      its(:source) { should == 'amadeus' }
      its(:subsource) { should == 'MOWR2233B' }

    end
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
    let(:discount_rule) { Discount::Rule.zero }

    before do
      Conf.payment.stub(:commission).and_return("2.85%")
      subject.stub(:commission => commission, :discount_rule => discount_rule)
    end

    context "no commission" do
      let(:commission) {nil}
      specify {
        expect {
          subject.income
        }.to raise_error
      }
    end

    context "with all the prices and direct commission" do
      let :commission do
        Commission::Rule.new(
          :agent => '4%',
          :subagent => '1%',
          :consolidator => '0',
          :blanks => '0',
          :ticketing_method => 'direct'
        )
      end
      let :discount_rule do
        Discount::Rule.new(
          :our_markup => '20',
          :discount => '3%',
        )
      end
      its('income.round') {should == 55}
    end

    context "with all the prices and aviacenter commission" do
      let :commission do
        Commission::Rule.new(
          :agent => '4%',
          :subagent => '1%',
          :consolidator => '2%',
          :blanks => '0',
          :ticketing_method => 'aviacenter'
        )
      end
      let :discount_rule do
        Discount::Rule.new(
          :our_markup => '20',
          :discount => '1%',
        )
      end
      its('income.round') {should == -37}
    end

  end

  describe "interline:" do

    # FIXME модифицировать прямо в before do?
    # прогнать, если фейлит
    # rails runner -e test "Carrier['AB'].update_attributes not_interlines: ['HG']"
    specify "following tests assumes that HG is in #not_interlines of Carrier['AB']" do
      Carrier['AB'].not_interlines.should include('HG')
    end

    let :not_interline do
      Recommendation.example('SVOCDG/AB', :carrier => 'AB')
    end
    let :partner_not_interline do
      Recommendation.example('SVOCDG/HG', :carrier => 'AB')
    end
    let :half_interline do
      Recommendation.example('SVOCDG/LH CDGSVO/AB', :carrier => 'AB')
    end
    let :partner_half_interline do
      Recommendation.example('SVOCDG/LH CDGSVO/HG', :carrier => 'AB')
    end
    let :interline_but_first do
      Recommendation.example('SVOCDG/AB CDGSVO/LH', :carrier => 'AB')
    end
    let :partner_interline_but_first do
      Recommendation.example('SVOCDG/HG CDGSVO/LH', :carrier => 'AB')
    end
    let :interline do
      Recommendation.example('SVOCDG/LH CDGSVO/LH', :carrier => 'AB')
    end
    let :codeshare do
      Recommendation.example('SVOCDG/AB:LH CDGSVO/LH', :carrier => 'AB')
    end

    # ugly
    it "#validating_carrier_participates?" do
      not_interline.validating_carrier_participates?.should be_true
      partner_not_interline.validating_carrier_participates?.should be_true
      half_interline.validating_carrier_participates?.should be_true
      partner_half_interline.validating_carrier_participates?.should be_true
      interline_but_first.validating_carrier_participates?.should be_true
      partner_interline_but_first.validating_carrier_participates?.should be_true
      interline.validating_carrier_participates?.should be_false
    end

    it "#validating_carrier_makes_half_of_itinerary?" do
      not_interline.validating_carrier_makes_half_of_itinerary?.should be_true
      partner_not_interline.validating_carrier_makes_half_of_itinerary?.should be_true
      half_interline.validating_carrier_makes_half_of_itinerary?.should be_true
      partner_half_interline.validating_carrier_makes_half_of_itinerary?.should be_true
      interline_but_first.validating_carrier_makes_half_of_itinerary?.should be_true
      partner_interline_but_first.validating_carrier_makes_half_of_itinerary?.should be_true
      interline.validating_carrier_makes_half_of_itinerary?.should be_false
    end

    it "#validating_carrier_starts_itinerary?" do
      not_interline.validating_carrier_starts_itinerary?.should be_true
      partner_not_interline.validating_carrier_starts_itinerary?.should be_true
      half_interline.validating_carrier_starts_itinerary?.should be_false
      partner_half_interline.validating_carrier_starts_itinerary?.should be_false
      interline_but_first.validating_carrier_starts_itinerary?.should be_true
      partner_interline_but_first.validating_carrier_starts_itinerary?.should be_true
      interline.validating_carrier_starts_itinerary?.should be_false
    end

    it "#interline?" do
      not_interline.interline?.should be_false
      partner_not_interline.interline?.should be_false
      half_interline.interline?.should be_true
      partner_half_interline.interline?.should be_true
      interline_but_first.interline?.should be_true
      interline.interline?.should be_true
    end

    it "#codeshare?" do
      not_interline.codeshare?.should be_false
      codeshare.codeshare?.should be_true
    end

  end
end

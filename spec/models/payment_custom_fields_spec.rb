# encoding: utf-8
require 'spec_helper'

describe PaymentCustomFields do
  describe "#flights=" do

    context "with one flight" do
      subject {
        described_class.new(
          :flights => [
            Flight.new( :departure_iata => 'SVO', :arrival_iata => 'CDG', :departure_date => '121212' )
          ]
        )
      }

      its(:segments) {should == 1}
      its(:points) {should == %W[SVO CDG]}
      its(:date) {should == Date.new(2012, 12, 12)}
    end

    context "with two flights" do
      subject {
        described_class.new(
          :flights => [
            Flight.new( :departure_iata => 'SVO', :arrival_iata => 'CDG', :departure_date => '121212' ),
            Flight.new( :departure_iata => 'CDG', :arrival_iata => 'SVO')
          ]
        )
      }

      its(:segments) {should == 2}
      its(:points) {should == %W[SVO CDG SVO]}
      its(:date) {should == Date.new(2012, 12, 12)}
    end

  end
end

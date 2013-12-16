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
      its(:airports) {should == 'SVO|CDG'}
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
      its(:airports) {should == 'SVO|CDG|SVO'}
      its(:date) {should == Date.new(2012, 12, 12)}
    end

  end

  describe '#order_form=' do
    context 'nationalities' do
      subject {
        of = OrderForm.new(people: people)
        of.stub_chain(:recommendation, :journey, :flights).and_return(nil)
        of.stub(:email).and_return('test@test.com')
        of.stub(:phone).and_return('+79251112233')
        described_class.new(
          order_form: of
        )
      }

      context 'one passenger' do
        let(:people){ [Person.new(nationality_code: 'RUS')] }

        its(:nationality){should == %W[RU]}
      end

      context 'multiple passengers' do
        let(:people){ [
            Person.new(nationality_code: 'RUS'),
            Person.new(nationality_code: 'USA'),
            Person.new(nationality_code: 'UKR'),
          ]
        }

        its(:nationality){should == %W[RU US UA]}
      end

      context 'weird nationalities' do
        let(:people){[
            Person.new(nationality_code: 'XXX'),
            Person.new(nationality_code: 'ARG'),
          ]
        }

        its(:nationality){should == [nil, 'AR']}
      end
    end
  end

  describe "#cleanup_email" do
    it "should return only first email out of two" do
      PaymentCustomFields.new.send(
        :cleanup_email, " foo@bar.com, test@example.com ").should == "foo@bar.com"
    end
  end
end

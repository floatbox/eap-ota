# encoding: utf-8
require 'spec_helper'

describe InsuranceHelper do

  describe '#smart_insurance_uri' do
    subject do
      smart_insurance_uri(order_form)
    end

    let(:people) do [
      Person.new(
        :first_name => 'Grown',
        :last_name => 'Up',
        :birthday => Date.today - 39.years,
        :document_expiration_date => Date.today + 1.year,
        :passport => '999999343',
        :sex => 'f'),
      Person.new(
        :first_name => 'Wanna',
        :last_name => 'Be',
        :birthday => Date.today - 2.years,
        :document_expiration_date => Date.today + 1.year,
        :passport => '999999343',
        :sex => 'm') ]
    end

    context "good order_form" do
      let(:flight) do
        Flight.new(
        :departure_iata => 'SVO',
        :departure_date => future_date,
        :arrival_date => future_date,
        :arrival_iata => 'MIA')
      end
      let(:variant) { Variant.new(:segments => [segment]) }
      let(:segment) {Segment.new(:flights => [flight])}
      let(:recommendation) { Recommendation.new(:variants => [variant]) }
      let(:order_form) { OrderForm.new(:recommendation => recommendation, :people => people, :email => "dear_friend@bat.man", :phone => '1111111')}

      let(:params) do {
        'start_date' => Date.parse(future_date.gsub(/^(\d\d)(\d\d?)(\d\d?)$/){"%02d.%02d.%02d" % [$1, $2, $3].map(&:to_i)}).strftime('%d.%m.%Y'),
        'end_date' => Date.parse(future_date(1).gsub(/^(\d\d)(\d\d?)(\d\d?)$/){"%02d.%02d.%02d" % [$1, $2, $3].map(&:to_i)}).strftime('%d.%m.%Y'),
        'country' => 'US',
        'city' => 'Москва',
        'phone' => '1111111',
        'email' => 'dear_friend@bat.man',
        'buyers' => {
          '0' => {
            'name' => 'Up',
            'surname' => 'Grown',
            'dob' => (Date.today - 39.years).strftime('%d.%m.Y'),
            'sex' => '1',
            'passport1' => '99',
            'passport2' => '9999343'
          },
          '1' => {
            'name' => 'Be',
            'surname' => 'Wanna',
            'dob' => (Date.today - 2.years).strftime('%d.%m.Y'),
            'sex' => '0',
            'passport1' => '99',
            'passport2' => '9999343'
          }
        }
      }
      end
      it {should == "http://www.smart-ins.ru/vzr_iframe/light?#{params.to_query}"}
    end

    context "bad order_form" do
      let(:order_form) { OrderForm.new(:recommendation => nil, :people => people, :email => "dear_friend@bat.man", :phone => '1111111')}
      it{ should be_nil}
    end
  end
end
# encoding: utf-8
require 'spec_helper'

describe InsuranceHelper do

  describe '#smart_insurance_uri' do

    def smart_insurance_date(date)
      date.strftime('%d.%m.%Y')
    end

    subject do
      smart_insurance_uri(order_form)
    end

    let(:people) do [
      Person.new(
        :first_name => 'Grown',
        :last_name => 'Up',
        :birthday => Date.today - 39.years,
        :document_expiration_date => Date.today + 1.year,
        :passport => '123999343',
        :sex => 'f'),
      Person.new(
        :first_name => 'Wanna',
        :last_name => 'Be',
        :birthday => Date.today - 2.years,
        :document_expiration_date => Date.today + 1.year,
        :passport => '999999342',
        :sex => 'm') ]
    end

    context "good order_form" do
      let(:flight) do
        Flight.new(
          :departure_iata => 'SVO',
          :dept_date => Date.tomorrow,
          :arrv_date => Date.tomorrow,
          :arrival_iata => 'MIA'
        )
      end
      let(:recommendation) { Recommendation.new(:flights => [flight]) }
      let(:order_form) { OrderForm.new(:recommendation => recommendation, :people => people, :email => "dear_friend@bat.man", :phone => '1111111')}

      let(:params) do {
        'start_date' => smart_insurance_date(flight.dept_date),
        'end_date' => smart_insurance_date(flight.dept_date + 30.days),
        'partner' => 'eviterra',
        'country' => 'US',
        'city' => 'Moscow',
        'phone' => '1111111',
        'email' => 'dear_friend@bat.man',
        'buyers' => {
          '0' => {
            'surname' => 'Up',
            'name' => 'Grown',
            'dob' => smart_insurance_date(Date.today - 39.years),
            'sex' => '1',
            'passport1' => '12',
            'passport2' => '3999343'
          },
          '1' => {
            'surname' => 'Be',
            'name' => 'Wanna',
            'dob' => smart_insurance_date(Date.today - 2.years),
            'sex' => '0',
            'passport1' => '99',
            'passport2' => '9999342'
          }
        }
      }
      end
      specify { params.should == insurance_uri_params(order_form) }
      it {should == "https://www.smart-ins.ru/vzr_iframe/light?#{params.to_query}"}

      context "but in russia!" do
        let(:flight) do
          Flight.new(
            :departure_iata => 'SVO',
            :dept_date => Date.tomorrow,
            :arrv_date => Date.tomorrow,
            :arrival_iata => 'ROV'
           )
         end

         it{ should be_nil }

      end
    end

    context "bad order_form" do
      let(:order_form) { OrderForm.new(:recommendation => nil, :people => people, :email => "dear_friend@bat.man", :phone => '1111111')}
      it{ should be_nil}
    end
  end
end

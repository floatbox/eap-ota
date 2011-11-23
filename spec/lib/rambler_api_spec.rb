# encoding: utf-8

require 'spec_helper'

describe RamblerApi do
  let(:flight1) do
    Flight.new(:operating_carrier_iata => 'SU',
      :marketing_carrier_iata => 'UN',
      :flight_number => '100',
      :departure_iata => 'SVO',
      :departure_date => '131211',
      :departure_time => '900',
      :arrival_date => '131211',
      :arrival_time => '1130',
      :arrival_iata => 'LED',
      :departure_term => 'F',
      :equipment_type_iata => '747')
  end
  let(:flight2) do
    Flight.new(:operating_carrier_iata => 'UN',
      :marketing_carrier_iata => 'UN',
      :flight_number => '200',
      :departure_iata => 'LED',
      :departure_date => '131211',
      :departure_time => '1400',
      :arrival_date => '131211',
      :arrival_time => '1700',
      :arrival_iata => 'LON',
      :departure_term => '1',
      :equipment_type_iata => 'TU3')
  end
  let(:flight3) do
    Flight.new(:operating_carrier_iata => 'BP',
      :marketing_carrier_iata => 'UN',
      :flight_number => '300',
      :departure_iata => 'LON',
      :departure_date => '141211',
      :departure_time => '1400',
      :arrival_date => '141211',
      :arrival_time => '1700',
      :arrival_iata => 'SVO',
      :departure_term => '1',
      :equipment_type_iata => 'TU3')
  end
  let(:segment1) {Segment.new(:flights => [flight1, flight2])}
  let(:segment2) {Segment.new(:flights => [flight3])}
  let(:variant)  {Variant.new(:segments => [segment1, segment2])}
  let(:recommendation) do
    Recommendation.new(
        :variants => [variant],
        :cabins => ['Y', 'Y', 'Y'],
        :source => 'amadeus',
        :booking_classes => ['M', 'N', 'K'],
        :validating_carrier_iata => 'SU',
        :price_fare => 1000,
        :price_tax => 2000,
        :price_our_markup => 0)
  end
  let(:pricer_form) do
    PricerForm.simple(
        :from => 'MOW',
        :to => 'LON',
        :date1 => '131211',
        :date2 => '141211',
        :adults => 2)
  end
  let(:request_params) do
    {:request => {
        :src => 'MOW',
        :dst => 'LON',
        :dir => '131211',
        :adt =>  2,
        :cls => nil
      },
      :response => {
        :va  => 'SU',
        :dir => [{
          :bcl => 'M',
          :cls => 'Y',
          :oa  => 'SU',
          :n   => '100',
          :ma  => 'UN',
          :dep =>{
            :p  => 'SVO',
            :dt => '131211'
            },
          :arr =>{
            :p => 'LED'
            }
          },
          {
          :bcl => 'N',
          :cls => 'Y',
          :oa  => 'UN',
          :n   => '200',
          :ma  => 'UN',
          :dep =>{
            :p  => 'LED',
            :dt => '131211'
            },
          :arr =>{
            :p => 'LON'
            }
          }],
        :ret => [{
          :bcl => 'K',
          :cls => 'Y',
          :oa  => 'BP',
          :n   => '300',
          :ma  => 'UN',
          :dep =>{
            :p  => 'LON',
            :dt => '141211'
            },
          :arr =>{
            :p => 'SVO'
            }
          }]
      }}
  end

  it 'should generate correct url' do
    uri = described_class.redirecting_uri request_params
    uri[:query_key].should_not be nil
    uri.should include(:recommendation => "amadeus.SU.M...SU:UN100SVOLED131211-UN200LEDLON131211.BP:UN300LONSVO141211")
  end

  it 'should generate correct hash' do
    described_class.generate_hash(pricer_form, recommendation).should == request_params
  end

  it 'should generate correct hash for rambler' do
    described_class.uri_for_rambler(request_params).should == "http://eviterra.com/api/manual_booking.xml?request%5Badt%5D=2&request%5Bcls%5D=&request%5Bdir%5D=131211&request%5Bdst%5D=LON&request%5Bsrc%5D=MOW&response%5Bdir%5D%5B%5D%5Barr%5D%5Bp%5D=LED&response%5Bdir%5D%5B%5D%5Bbcl%5D=M&response%5Bdir%5D%5B%5D%5Bcls%5D=Y&response%5Bdir%5D%5B%5D%5Bdep%5D%5Bdt%5D=131211&response%5Bdir%5D%5B%5D%5Bdep%5D%5Bp%5D=SVO&response%5Bdir%5D%5B%5D%5Bma%5D=UN&response%5Bdir%5D%5B%5D%5Bn%5D=100&response%5Bdir%5D%5B%5D%5Boa%5D=SU&response%5Bdir%5D%5B%5D%5Barr%5D%5Bp%5D=LON&response%5Bdir%5D%5B%5D%5Bbcl%5D=N&response%5Bdir%5D%5B%5D%5Bcls%5D=Y&response%5Bdir%5D%5B%5D%5Bdep%5D%5Bdt%5D=131211&response%5Bdir%5D%5B%5D%5Bdep%5D%5Bp%5D=LED&response%5Bdir%5D%5B%5D%5Bma%5D=UN&response%5Bdir%5D%5B%5D%5Bn%5D=200&response%5Bdir%5D%5B%5D%5Boa%5D=UN&response%5Bret%5D%5B%5D%5Barr%5D%5Bp%5D=SVO&response%5Bret%5D%5B%5D%5Bbcl%5D=K&response%5Bret%5D%5B%5D%5Bcls%5D=Y&response%5Bret%5D%5B%5D%5Bdep%5D%5Bdt%5D=141211&response%5Bret%5D%5B%5D%5Bdep%5D%5Bp%5D=LON&response%5Bret%5D%5B%5D%5Bma%5D=UN&response%5Bret%5D%5B%5D%5Bn%5D=300&response%5Bret%5D%5B%5D%5Boa%5D=BP&response%5Bva%5D=SU"
  end

end
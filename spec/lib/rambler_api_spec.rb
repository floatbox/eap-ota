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
      :arrival_iata => 'YXU',
      :departure_term => '1',
      :equipment_type_iata => 'TU3')
  end
  let(:flight3) do
    Flight.new(:operating_carrier_iata => 'BP',
      :marketing_carrier_iata => 'UN',
      :flight_number => '300',
      :departure_iata => 'YXU',
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
        :price_tax => 2000
    )
  end
  let(:yamled_params){"dir%5B0%5D%5Barr%5D%5Bp%5D=LED&dir%5B0%5D%5Bbcl%5D=M&dir%5B0%5D%5Bcls%5D=E&dir%5B0%5D%5Bdep%5D%5Bdt%5D=131211&dir%5B0%5D%5Bdep%5D%5Bp%5D=SVO&dir%5B0%5D%5Bma%5D=UN&dir%5B0%5D%5Bn%5D=100&dir%5B0%5D%5Boa%5D=SU&dir%5B1%5D%5Barr%5D%5Bp%5D=YXU&dir%5B1%5D%5Bbcl%5D=N&dir%5B1%5D%5Bcls%5D=E&dir%5B1%5D%5Bdep%5D%5Bdt%5D=131211&dir%5B1%5D%5Bdep%5D%5Bp%5D=LED&dir%5B1%5D%5Bma%5D=UN&dir%5B1%5D%5Bn%5D=200&dir%5B1%5D%5Boa%5D=UN&ret%5B0%5D%5Barr%5D%5Bp%5D=SVO&ret%5B0%5D%5Bbcl%5D=K&ret%5B0%5D%5Bcls%5D=E&ret%5B0%5D%5Bdep%5D%5Bdt%5D=141211&ret%5B0%5D%5Bdep%5D%5Bp%5D=YXU&ret%5B0%5D%5Bma%5D=UN&ret%5B0%5D%5Bn%5D=300&ret%5B0%5D%5Boa%5D=BP&va=SU"}
  let(:request_params) do
    {
      :va  => 'SU',
      :dir => { 0 =>
        {
          :bcl => 'M',
          :cls => 'E',
          :oa  => 'SU',
          :n   => '100',
          :ma  => 'UN',
          :dep => {
            :p  => 'SVO',
            :dt => '131211'
          },
          :arr => {
            :p => 'LED'
          }
      }, 1 =>
      {
          :bcl => 'N',
          :cls => 'E',
          :oa  => 'UN',
          :n   => '200',
          :ma  => 'UN',
          :dep => {
            :p  => 'LED',
            :dt => '131211'
          },
          :arr => {
            :p => 'YXU'
          }
        }
      },
    :ret => {0 =>
        {
          :bcl => 'K',
          :cls => 'E',
          :oa  => 'BP',
          :n   => '300',
          :ma  => 'UN',
          :dep => {
            :p  => 'YXU',
            :dt => '141211'
          },
          :arr => {
            :p => 'SVO'
          }
        }}

    }
  end

  it 'should generate correct url' do
    uri = described_class.redirecting_uri request_params
    uri[:query_key].should_not be_nil
    uri.should include(:recommendation => "amadeus.SU.MNK.YYY..SU:UN100SVOLED131211-UN200LEDYXU131211.BP:UN300YXUSVO141211")
  end

  it 'should generate correct hash' do
    described_class.generate_hash(recommendation).should == request_params
  end

  it 'should generate correct hash for rambler' do
    described_class.uri_for_rambler(request_params).should == "http://eviterra.com/api/rambler_booking.xml?#{yamled_params}"
  end

end
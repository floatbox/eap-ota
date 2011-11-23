# encoding: utf-8
require 'spec_helper'

describe RamblerCache do

  describe '#rambler_data_from_recs' do

    before(:each) do
      fl1 = Flight.new(:operating_carrier_iata => 'SU',
        :marketing_carrier_iata => 'UN',
        :flight_number => 100,
        :departure_iata => 'SVO',
        :departure_date => '131211',
        :departure_time => '900',
        :arrival_date => '131211',
        :arrival_time => '1130',
        :arrival_iata => 'LED',
        :departure_term => 'F',
        :equipment_type_iata => '747')
      fl2 = Flight.new(:operating_carrier_iata => 'UN',
        :marketing_carrier_iata => 'UN',
        :flight_number => 200,
        :departure_iata => 'LED',
        :departure_date => '131211',
        :departure_time => '1400',
        :arrival_date => '131211',
        :arrival_time => '1700',
        :arrival_iata => 'LON',
        :departure_term => '1',
        :equipment_type_iata => 'TU3')
      fl3 = Flight.new(:operating_carrier_iata => 'BP',
        :marketing_carrier_iata => 'UN',
        :flight_number => 300,
        :departure_iata => 'LON',
        :departure_date => '141211',
        :departure_time => '1400',
        :arrival_date => '141211',
        :arrival_time => '1700',
        :arrival_iata => 'SVO',
        :departure_term => '1',
        :equipment_type_iata => 'TU3')
      seg1 = Segment.new(:flights => [fl1, fl2])
      seg2 = Segment.new(:flights => [fl3])
      variant = Variant.new(:segments => [seg1, seg2])
      recommendation = Recommendation.new(:variants => [variant], :cabins => ['Y', 'Y', 'Y'], :source => 'amadeus', :booking_classes => ['M', 'N', 'K'], :validating_carrier_iata => 'SU', :price_fare => 1000, :price_tax => 2000, :price_our_markup => 0)
      pricer_form = PricerForm.simple(:from => 'MOW', :to => 'LON', :date1 => '131211', :date2 => '141211', :adults => 2)
      @result = RamblerCache.from_form_and_recs(pricer_form, [recommendation]).data[0]
    end

    it 'sets correct cabins' do
      @result['dir'].map{|segment| segment['cls']}.should == ['E', 'E']
      @result['ret'].map{|segment| segment['cls']}.should == ['E']
    end

    it 'sets correct times' do
      @result['dir'][0]['dep']['dt'].should == '2011-12-13 09:00:00'
      @result['ret'][0]['arr']['dt'].should == '2011-12-14 17:00:00'
    end
  end
end

# encoding: utf-8
require 'spec_helper'

describe Amadeus::Response::FareMasterPricerTravelBoardSearch, amadeus: true do
  context 'with NO ITINERARY FOUND' do

    let_once! :response do
      amadeus_response('spec/amadeus/xml/Fare_MasterPricerTravelBoardSearch_NoItineraryFoundError.xml')
    end

    subject { response }

    it { should_not be_success }
    its(:error_message) { should == 'NO ITINERARY FOUND FOR REQUESTED SEGMENT 2' }
    its(:error_code) { should == '931' }
    its(:recommendations) { should be_empty }

  end

  context 'with some crazy passengers and itinerary' do

    let_once! :response do
      amadeus_response('spec/amadeus/xml/Fare_MasterPricerTravelBoardSearch_Pathological.xml')
    end

    describe "response" do
      subject { response }
      it { should be_success }
      its(:error_message) { should be_blank }
      it { should have(3).recommendations }

      describe 'first recommendations' do

        let_once!(:recommendation) { response.recommendations.first }
        subject { recommendation }

        it { should have(4).flights }
        it { should have(1).variant }

        its(:blank_count) { should == 4 }
        its(:validating_carrier_iata) { should == 'OS'}
        its(:cabins) { should == %W( M M M M ) }
        its(:booking_classes) { should == %W( T T T T ) }

        its(:price_fare) { should == 22480.0 }
        its(:price_tax) { should == 20656.0 }
        its(:last_tkt_date) { should == Date.parse("30APR11") }

        describe 'variant' do
          let_once!(:variant) { recommendation.variants.first }
          subject { variant }

          it { should have(2).segments }
          its('segments.first') { should have(2).flights }
          its('segments.last') { should have(2).flights }
          it { should have(4).flights }

          describe 'first segment' do
            let_once!(:segment) { variant.segments.first }
            subject {segment}

            its(:total_duration) { should == 1160 }

            describe 'first flight' do
              let_once!(:flight) { segment.flights.first }
              subject { flight }

              its(:technical_stop_count) { should == 0 }
              its(:technical_stops) { should == [] }
              its(:departure_iata) { should == 'ROV' }
              its(:arrival_iata) { should == 'VIE' }
              its(:marketing_carrier_iata) { should == 'OS'}
              its(:operating_carrier_iata) { should == 'VO'}
              its(:equipment_type_iata) { should == 'F70'}
              its(:departure_date) { should == '200511'}
              its(:departure_time) { should == '1540'}
              its(:arrival_date) { should == '200511'}
              its(:arrival_time) { should == '1640'}

              its(:duration) { should == 180 }
            end

            describe 'second flight with incomplete terminals' do
              let_once!(:flight) { segment.flights.second }
              subject { flight }

              its(:arrival_term) { should == '1' }
              its(:departure_term) { should be_nil }
            end

            describe 'last flight' do
              let_once!(:flight) { segment.flights.last }
              subject { flight }

              its(:departure_iata) { should == 'VIE' }
              its(:arrival_iata) { should == 'LHR' }
              its(:marketing_carrier_iata) { should == 'OS'}
              its(:operating_carrier_iata) { should == 'OS'}
              its(:equipment_type_iata) { should == '738'}
              its(:departure_date) { should == '210511'}
              its(:departure_time) { should == '0635'}
              its(:arrival_date) { should == '210511'}
              its(:arrival_time) { should == '0800'}

              its(:duration) { should == 145 }
            end

          end
        end
      end
    end
  end

  context 'with two technical stops' do

    let_once! :response do
      amadeus_response('spec/amadeus/xml/Fare_MasterPricerTravelBoardSearch_with_stops.xml')
    end

    describe "response" do
      subject { response }
      it { should be_success }
      its(:error_message) { should be_blank }
      it { should have(1).recommendations }

      describe 'first recommendations' do

        let_once!(:recommendation) { response.recommendations.first }
        subject { recommendation }

        it { should have(1).flight }
        it { should have(1).variant }

        its(:blank_count) { should == 1 }
        its(:cabins) { should == %W( M ) }
        its(:booking_classes) { should == %W( V ) }

        its(:price_fare) { should == 15000.0 }
        its(:price_tax) { should == 122.0 }

        describe 'variant' do
          let_once!(:variant) { recommendation.variants.first }
          subject { variant }

          it { should have(1).segment }
          it { should have(1).flight }

          describe 'first segment' do
            let_once!(:segment) { variant.segments.first }
            subject {segment}

            its(:total_duration) { should == 775 }
            it { should have(1).flight }

            describe 'first flight' do
              let_once!(:flight) { segment.flights.first }
              subject { flight }

              # ради этого все затевалось
              its(:technical_stop_count) { should == 2 }
              its('technical_stops.first.location_iata') { should == 'SVX' }
              its('technical_stops.last.location_iata') { should == 'OVB' }

              # просто на всякий случай
              its(:departure_iata) { should == 'LED' }
              its(:arrival_iata) { should == 'KHV' }
              its(:marketing_carrier_iata) { should == 'U6'}
              its(:operating_carrier_iata) { should == 'U6'}
              its(:equipment_type_iata) { should == '320'}
              its(:departure_date) { should == '290711'}
              its(:departure_time) { should == '1445'}
              its(:arrival_date) { should == '300711'}
              its(:arrival_time) { should == '1040'}

              its(:duration) { should == 775 }
            end
          end
        end
      end
    end
  end

end


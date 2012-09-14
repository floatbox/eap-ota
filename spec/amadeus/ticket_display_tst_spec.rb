# encoding: utf-8
require 'spec_helper'

describe Amadeus::Response::TicketDisplayTST do

  describe '#baggage_with_refs' do
    context 'with different baggage' do
      subject_once! {
        amadeus_response('spec/amadeus/xml/Ticket_DisplayTST_with_different_baggage.xml')
      }

      its('baggage_with_refs.keys.sort') {should == [[11, "a"], [12, "a"], [12, "i"]]}
      specify {subject.baggage_with_refs[[11, "a"]].keys.sort.should == [1, 2]}
      specify {subject.baggage_with_refs[[12, 'i']][1].kilos.should == 10}
      specify {subject.baggage_with_refs[[11, 'a']][1].units.should == 1}
      specify {subject.baggage_with_refs[[11, 'a']][1].units?.should be_true}
      specify {subject.baggage_for_segments[2].units?.should be_true}
      specify {subject.baggage_for_segments[2].units.should == 1}
    end

    context 'with two simular persons' do

      subject_once! {
        amadeus_response('spec/amadeus/xml/Ticket_DisplayTST_for_two.xml')
      }
      specify {subject.baggage_with_refs.keys.sort.should == [[12, "a"], [13, 'a']]}
    end
  end

  describe 'adult with infant' do

    subject_once! {
      amadeus_response('spec/amadeus/xml/Ticket_DisplayTST_With_Infant.xml')
    }

    it { should be_success }
    specify { subject.prices_with_refs.should have(2).keys }
    specify { subject.prices_with_refs[[[7, 'a'], [1]]].should == {:price_fare => 5985,:price_fare_base => 5985,  :price_tax => 656, :original_fare_cents => 598500,:original_fare_currency => "RUB", :original_tax_cents => 65600, :original_tax_currency => "RUB"}}
    specify { subject.prices_with_refs[[[7, 'i'], [1]]].should == {:price_fare_base => 600, :price_fare => 600, :price_tax => 171, :original_fare_cents => 60000,:original_fare_currency => "RUB", :original_tax_cents => 17100, :original_tax_currency => "RUB"}}
    its(:total_fare) { should == 6585 }
    its(:total_tax) { should == 827 }
    its(:validating_carrier_code) { should == 'FV' }
    its(:last_tkt_date) { should == Date.new(2011, 4, 14) }
    its(:blank_count) { should == 2 }
  end

  describe 'two adults' do

    subject_once! {
      amadeus_response('spec/amadeus/xml/Ticket_DisplayTST_for_two.xml')
    }

    it { should be_success }
    specify { subject.prices_with_refs.should have(2).keys }
    specify { subject.prices_with_refs.values[0].should == {:price_fare_base => 3825, :price_fare => 3825, :price_tax => 3905,:original_fare_cents => 382500, :original_fare_currency => "RUB",:original_tax_cents => 390500, :original_tax_currency => "RUB"} }
    its(:total_fare) { should == 7650 }
    its(:total_tax) { should == 7810 }
    its(:validating_carrier_code) { should == 'LH' }
    its(:last_tkt_date) { should == Date.new(2011, 8, 31) }
    its(:blank_count) { should == 2 }
  end


  describe 'complex tickets' do
      subject_once! {
        amadeus_response('spec/amadeus/xml/Ticket_DisplayTST_complex_tickets.xml')
      }
      its('prices_with_refs.keys.length'){should == 4}
      its('prices_with_refs.keys'){should include([[2, 'a'], [5, 6, 7, 8]])}
      its('prices_with_refs.keys'){should include([[1, 'a'], [5, 6, 7, 8]])}
      its('prices_with_refs.keys'){should include([[1, 'a'], [11, 12]])}
      its('prices_with_refs.keys'){should include([[2, 'a'], [11, 12]])}
      specify{subject.prices_with_refs[[[2, 'a'], [5, 6, 7, 8]]][:price_tax].should == 7814}
      specify{subject.prices_with_refs[[[2, 'a'], [5, 6, 7, 8]]][:price_fare].should == 7600}
      specify{subject.money_with_refs[[[2, 'a'], [5, 6, 7, 8]]][:price_tax].should == 7814.to_money("RUB")}
      specify{subject.money_with_refs[[[2, 'a'], [5, 6, 7, 8]]][:price_fare].should == 7600.to_money("RUB")}
      its(:blank_count) {should == 4}

  end

  describe 'tst from booking' do

    subject_once! {
      amadeus_response('spec/amadeus/xml/Ticket_DisplayTST_without_tickets.xml')
    }
    its(:total_fare) { should == 39860}
    its(:total_tax) { should == 15879 }
    its(:blank_count) { should == 3 }
  end

  describe 'with ticketingStatus NO' do

    subject_once! {
      amadeus_response('spec/amadeus/xml/Ticket_DisplayTST_with_ticketingStatus_no.xml')
    }

    its('prices_with_refs.keys.every.second.flatten.uniq') {should_not include(2)}
    its('prices_with_refs.keys.every.second.flatten.uniq') {should include(1)}
  end

  describe 'with no tst on order' do
    subject_once! { amadeus_response('spec/amadeus/xml/Ticket_DisplayTST_no_tst.xml') }

    it {should_not be_success}
    its(:error_message) {should == "NO TST RECORD EXISTS :"}
  end

  describe 'when american office' do
    subject_once! { amadeus_response('spec/amadeus/xml/Ticket_DisplayTST_american_office.xml')}

    # specify {subject.total_fare.should == 576.00}
    its(:total_fare_money) { should == 576.to_money("USD") }
    its(:total_tax_money) { should == 19.22.to_money("USD") }
  end

  describe 'when loading exchange on a very old ticket' do
    subject_once! { amadeus_response('spec/amadeus/xml/Ticket_DisplayTST_old_with_empty_values.xml')}
    pending "react sensibly"
  end
end


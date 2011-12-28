# encoding: utf-8
require 'spec_helper'

describe Sirena::Response::Order do


  describe 'with one adult, unpaid' do

    let(:response) { 'spec/sirena/xml/order.xml' }
    subject_once! { described_class.new( File.read(response) ) }

    it { should be_success }
    its(:number) { should == '08ВГЦП' }
    it { should have(1).passenger }
    its("passengers.every.first_name") { should == ['ALEKSEY'] }
    its("passengers.every.tickets") { should == [[]] }
    its("passengers.every.last_name") { should == ['TROFIMENKO'] }
    its("passengers.every.passport") { should == ['6555555555'] }
    # теперь там контакт евитерры
    #its(:email) { should == 'USER@EXAMPLE.COM' }
    its(:phone) { should == '+79265555555' }
    it { should have(2).flights }
    its(:booking_classes) { should == %W(Y Y) }
  end

  describe 'adult and child, ticketed' do

    let(:response) { 'spec/sirena/xml/order_with_tickets.xml' }
    subject_once! { described_class.new( File.read(response) ) }

    it { should be_success }
    its(:number) { should == '08ВМГХ' }
    it { should have(2).passengers }
    its("passengers.every.first_name") { should == ["ALEKSEY", "MASHA"] }
    its("passengers.every.last_name") { should == ['IVANOV', 'IVANOVA'] }
    its("passengers.every.passport") { should == ["6555555555", "VВГ123456"] }
    specify { subject.passengers.map{ |p| p.tickets.every.number_with_code}.should ==  [ ['262-6150600213'], ['262-6150600214']]}
    specify {subject.ticket_hashes.every[:status].should == ['ticketed', 'ticketed']}
    # теперь там контакт евитерры
    #its(:email) { should == 'USER@EXAMPLE.COM' }
    its(:phone) { should == '+79265555555' }
    it { should have(2).flights }
    its(:booking_classes) { should == %W(Y Y) }
    specify{(subject.ticket_hashes.every[:number]).should == [ '6150600213', '6150600214']}
    specify{(subject.ticket_hashes.every[:code]).should == ['262', '262']}
    specify{(subject.ticket_hashes.every[:price_fare]).should == [ 2000, 1000]}
    specify{(subject.ticket_hashes.every[:price_tax]).should == [ 2000, 2000]}
    specify{(subject.ticket_hashes.every[:route]).should == [ "ДМД - ПЛК (U6); ПЛК - ДМД (U6)", "ДМД - ПЛК (U6); ПЛК - ДМД (U6)"]}
    specify{(subject.ticket_hashes.every[:cabins]).should == [ "Y", "Y"]}
    specify{(subject.ticket_hashes.every[:first_name]).should == ["ALEKSEY", "MASHA"]}
    specify{(subject.ticket_hashes.every[:last_name]).should == ["IVANOV", "IVANOVA"]}
    specify{(subject.ticket_hashes.every[:passport]).should == ["6555555555", "VВГ123456"]}
  end

  describe 'when airport is not reported' do

    let(:response) { 'spec/sirena/xml/order_without_arrival_airport.xml' }
    subject_once! { described_class.new( File.read(response) ) }

    it { should be_success }
    it { should have(1).flights }
    specify { subject.flights.first.arrival.city.name.should == 'Воронеж' }
  end

  describe 'tickets after reissue' do

    let(:response) { 'spec/sirena/xml/order_with_broken_tickets.xml' }
    subject_once! { described_class.new( File.read(response) ) }

    it { should be_success }
    pending "should be ok for storage and display"
  end
end


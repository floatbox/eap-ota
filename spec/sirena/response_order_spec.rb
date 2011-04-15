# encoding: utf-8
require 'spec_helper'

describe Sirena::Response::Order do

  subject { described_class.new( File.read(response) ) }

  describe 'with one adult, unpaid' do

    let(:response) { 'spec/sirena/xml/order.xml' }

    it { should be_success }
    its(:number) { should == '08ВГЦП' }
    it { should have(1).passenger }
    its("passengers.every.first_name") { should == ['ALEKSEY 19МАР83'] }
    its("passengers.every.ticket") { should == [nil] }
    its("passengers.every.last_name") { should == ['TROFIMENKO'] }
    its("passengers.every.passport") { should == ['6555555555'] }
    its(:email) { should == 'USER@EXAMPLE.COM' }
    its(:phone) { should == '+79265555555' }
    it { should have(2).flights }
    its(:booking_classes) { should == %W(Y Y) }
  end

  describe 'adult and child, ticketed' do

    let(:response) { 'spec/sirena/xml/order_with_tickets.xml' }

    it { should be_success }
    its(:number) { should == '08ВМГХ' }
    it { should have(2).passengers }
    its("passengers.every.first_name") { should == ["ALEKSEY 19АПР83", "MASHA 20ФЕВ00"] }
    its("passengers.every.last_name") { should == ['IVANOV', 'IVANOVA'] }
    its("passengers.every.passport") { should == ["6555555555", "VВГ123456"] }
    its ("passengers.every.ticket") { should == [ '2626150600213', '2626150600214'] }
    its(:email) { should == 'USER@EXAMPLE.COM' }
    its(:phone) { should == '+79265555555' }
    it { should have(2).flights }
    its(:booking_classes) { should == %W(Y Y) }
  end
end

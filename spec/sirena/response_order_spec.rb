# encoding: utf-8
require 'spec_helper'

describe Sirena::Response::Order do
  describe 'with one adult, unpaid' do

    subject {
      body = File.read('spec/sirena/xml/order.xml')
      Sirena::Response::Order.new(body)
    }

    it { should be_success }
    its(:number) { should == '08ВГЦП' }
    it { should have(1).passenger }
    specify { subject.passengers.collect(&:first_name).should == ['ALEKSEY 19МАР83'] }
    specify { subject.passengers.collect(&:ticket).should == [nil] }
    specify { subject.passengers.collect(&:last_name).should == ['TROFIMENKO'] }
    specify { subject.passengers.collect(&:passport).should == ['6555555555'] }
    its(:email) { should == 'USER@EXAMPLE.COM' }
    its(:phone) { should == '+79265555555' }
    it { should have(2).flights }
    its(:booking_classes) { should == %W(Y Y) }
  end

  describe 'adult and child, ticketed' do

    subject {
      body = File.read('spec/sirena/xml/order_with_tickets.xml')
      Sirena::Response::Order.new(body)
    }

    it { should be_success }
    its(:number) { should == '08ВМГХ' }
    it { should have(2).passengers }
    specify { subject.passengers.collect(&:first_name).should == ["ALEKSEY 19АПР83", "MASHA 20ФЕВ00"] }
    specify { subject.passengers.collect(&:ticket).should == [ '2626150600213', '2626150600214'] }
    specify { subject.passengers.collect(&:last_name).should == ['IVANOV', 'IVANOVA'] }
    specify { subject.passengers.collect(&:passport).should == ["6555555555", "VВГ123456"] }
    its(:email) { should == 'USER@EXAMPLE.COM' }
    its(:phone) { should == '+79265555555' }
    it { should have(2).flights }
    its(:booking_classes) { should == %W(Y Y) }
  end
end

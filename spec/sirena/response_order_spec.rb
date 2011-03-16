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
    # specify { subject.passengers.collect(&:ticket).should == %W( 220-2791248713 220-2791248714 220-2791248716 220-2791248715 ) }
    specify { subject.passengers.collect(&:last_name).should == ['TROFIMENKO'] }
    specify { subject.passengers.collect(&:passport).should == ['6555555555'] }
    its(:email) { should == 'USER@EXAMPLE.COM' }
    its(:phone) { should == '+79265555555' }
    it { should have(2).flights }
    its(:booking_classes) { should == %W(Y Y) }
  end
end

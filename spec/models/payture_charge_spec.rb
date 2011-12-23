# encoding: utf-8
require 'spec_helper'

describe PaytureCharge do
  include Commission::Fx

  it 'should recalculate earnings on save' do
    p = PaytureCharge.new :commission => '1.23%', :price => 1000
    p.save!
    p.commission.should == Fx('1.23%')
    p.earnings.should == 1000 - 12.3
  end

  it 'probably should get commission from Conf, if unset' do
    Conf.payture.stub(:commission).and_return('3.45%')
    p = PaytureCharge.new :price => 1000
    p.save!
    p.commission.should == Fx('3.45%')
    p.earnings.should == 1000 - 34.5
  end
end

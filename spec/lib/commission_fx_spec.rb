# encoding: utf-8

require 'spec_helper'

describe Commission::Fx do
  include Commission::Fx

  describe "#Fx" do
    it "should create new Commission::Formula" do
      Fx('2%').should == Commission::Formula.new('2%')
    end
  end
end

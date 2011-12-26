# encoding: utf-8
require 'spec_helper'

describe CreditCard do

  describe "#masked_pan" do
    it "should mask 10 digits inbetween" do
      CreditCard.new(:number => '1234567890123456').pan.should == '123456xxxxxx3456'
    end
  end

end

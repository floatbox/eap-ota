# encoding: utf-8
require 'spec_helper'

describe CreditCard do

  describe "#masked_pan" do
    it "should mask 10 digits inbetween" do
      CreditCard.new(:number => '1234567890123456').pan.should == '123456xxxxxx3456'
    end
  end

  describe "#split card holder name" do
    subject { CreditCard.new(:name => "ANDREY AREFYEV") }

    its(:first_name) { should == "ANDREY" }
    its(:last_name) { should == "AREFYEV" }
  end

  describe ".example" do
    subject { CreditCard.example("5486732058864471        123     12/15 no name") }

    its(:number) { should == "5486732058864471" }
    its(:verification_value) { should == "123" }
    its(:month) { should == 12 }
    its(:year) { should == 2015 }
    its(:name) { should == "no name" }

  end

end

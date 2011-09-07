# encoding: utf-8

require 'spec_helper'

describe CastingAccessors do

  class TestClassWithCastingAccessors
    extend CastingAccessors
    attr_accessor :mybool
    cast_to_boolean :mybool
  end

  let(:obj) { TestClassWithCastingAccessors.new }

  it "shoold not change defaults, I think" do
    obj.mybool.should == nil
  end

  it "should accept true" do
    obj.mybool = true
    obj.mybool.should == true
  end

  it "should accept '1'" do
    obj.mybool = "1"
    obj.mybool.should == true
  end

  it "should accept false" do
    obj.mybool = false
    obj.mybool.should == false
  end

  it "should accept empty string" do
    obj.mybool = ""
    obj.mybool.should == false
  end

end

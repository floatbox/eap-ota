# encoding: utf-8

require 'spec_helper'
describe Commission::Includesonly do

  before do
    extend Commission::Includesonly
  end

  describe "#includes" do
    
    it "should be true for equal lists" do
      includes( ['SVO'], ['SVO'] ).should == true
    end

    specify { includes( ['SVO', 'CDG'], ['DME', 'SVO'] ).should == true }
    specify { includes( ['SVO', 'CDG'], ['DME'] ).should == false }
    specify { includes( 'SVO', 'SVO' ).should == true }
    specify { includes( 'SVO CDG', 'SVO' ).should == true }
    specify { includes( 'SVO CDG', 'DME SVO' ).should == true }
  end

  describe "#includes_only" do
    it "should be true for equal lists" do
      includes_only( ['SVO'], ['SVO'] ).should == true
    end

    it "should be true when first set is a subset of second set" do
      includes_only( ['SVO'], ['SVO', 'DME'] ).should == true
    end

    it "should be false when second set is only a partial subset of first set" do
      includes_only( ['SVO', 'DME'], ['SVO'] ).should == false
    end

    specify { includes_only( ['SVO', 'CDG'], ['DME', 'SVO'] ).should == false }
    specify { includes_only( ['SVO', 'CDG', 'SVO'], ['CDG', 'SVO'] ).should == true }
    specify { includes_only( ['SVO', 'CDG'], ['DME'] ).should == false }
    specify { includes_only( 'SVO', 'SVO' ).should == true }
    specify { includes_only( 'SVO CDG SVO', 'SVO CDG' ).should == true }
  end
end

# encoding: utf-8
require 'spec_helper'

describe Commission::Formula do
  specify { Commission::Formula.new("3").call.should == 3 }
  specify { Commission::Formula.new("3.5").call.should == 3.5 }
  specify { Commission::Formula.new("3.5").call(23).should == 3.5 }
  specify { Commission::Formula.new("3.5%").call(200).should == 7 }
  specify { Commission::Formula.new("3.5%")[200].should == 7 }
  specify { Commission::Formula.new("2% + 4").to_s.should == "2% + 4" }
  specify { Commission::Formula.new("3.5").should be_valid }
  specify { Commission::Formula.new(" 12.34%").should be_valid }
  specify { Commission::Formula.new("12,34%").should_not be_valid }

  specify { Commission::Formula.new("12.3eur").should be_valid }
  specify { Commission::Formula.new("12.3eur").call(42, :eur => 43.2).should == 531.36 }

  context "it accepts Numerics" do
    specify { Commission::Formula.new(23.45).should be_valid }
    specify { Commission::Formula.new(23.45).call.should == 23.45 }
  end

  context "works with multiplier" do
    specify { Commission::Formula.new("3.5%").call(200, :multiplier => 2).should == 7 }
    specify { Commission::Formula.new("3.6").call(200, :multiplier => 2).should == 7.2 }
    specify { Commission::Formula.new("1.1eur").call(200, :eur => 24.2, :multiplier => 2).should == 53.24 }
  end

  context "it should round to 2 digits by default" do
    specify { Commission::Formula.new("3.235%").call(500).should == 16.18 }
  end

  it "should be equal to the same formula" do
    Commission::Formula.new('3.34%').should == Commission::Formula.new('3.34%')
  end

  it "should be serializable by YAML" do
    formula = Commission::Formula.new('3.34%')
    YAML.load(YAML.dump(formula)).should == formula
  end

  pending "it should have exactly that serialization" do
    # backward compatibility?
  end

  pending "should work with sums" do
    Commission::Formula.new("2% + 4").should be_valid
  end
end

# encoding: utf-8
require 'spec_helper'

describe Commission::Formula do
  include Commission::Fx
  specify { Fx("3").call.should == 3 }
  specify { Fx("3.5").call.should == 3.5 }
  specify { Fx("3.5").call(23).should == 3.5 }
  specify { Fx("3.5%").call(200).should == 7 }
  specify { Fx("3.5%")[200].should == 7 }
  specify { Fx("2% + 4").to_s.should == "2% + 4" }
  specify { Fx("3.5").should be_valid }
  specify { Fx(" 12.34%").should be_valid }
  specify { Fx("12,34%").should_not be_valid }

  specify { Fx("12.3eur").should be_valid }
  specify { Fx("12.3eur").call(42, :eur => 43.2).should == 531.36 }

  context "it accepts Numerics" do
    specify { Fx(23.45).should be_valid }
    specify { Fx(23.45).call.should == 23.45 }
  end

  context "it works with empty values" do
    specify { Fx("").should be_valid }
    specify { Fx("").call.should == 0 }

    specify { Fx(nil).should be_valid }
    specify { Fx(nil).call.should == 0 }
  end

  context "works with multiplier" do
    specify { Fx("3.5%").call(200, :multiplier => 2).should == 7 }
    specify { Fx("3.6").call(200, :multiplier => 2).should == 7.2 }
    specify { Fx("1.1eur").call(200, :eur => 24.2, :multiplier => 2).should == 53.24 }
  end

  context "it should round to 2 digits by default" do
    specify { Fx("3.235%").call(500).should == 16.18 }
  end

  it "should be equal to the same formula" do
    Fx('3.34%').should == Fx('3.34%')
  end

  it "should be serializable by YAML" do
    formula = Fx('3.34%')
    YAML.load(YAML.dump(formula)).should == formula
  end

  describe "#serialize" do
    specify { Fx('3.34%').inspect.should == '#<Fx 3.34% >' }
  end

  pending "it should have exactly that serialization" do
    # backward compatibility?
  end

  describe "#zero?" do
    specify { Fx('0').should be_zero }
    specify { Fx('0.00').should be_zero }
    specify { Fx(0.0).should be_zero }
    specify { Fx('').should be_zero }
    specify { Fx(nil).should be_zero }
  end

  describe "#blank?" do
    specify { Fx('').should be_blank }
    specify { Fx(' ').should be_blank }
    specify { Fx(nil).should be_blank }
    specify { Fx(0).should_not be_blank }
    specify { Fx('0%').should_not be_blank }
  end

  context "formula with sums" do
    subject {Fx("2.5% + 4")}

    it {should be_valid}
    it {should be_complex}

    it "should be able to campute" do
      subject.call(100).should == 6.5
    end

    it "should compute with multipliers" do
      subject.call(100, :multiplier => 4).should == 18.5
    end

    context "used in not intended ways" do
      it "should die" do
        expect {subject.percentage?}.to raise_error
      end

      it "should die again" do
        expect {subject.euro?}.to raise_error
      end

      it "should die again and again" do
        expect {subject.rate}.to raise_error
      end
    end
  end

  context "invalid formula" do
    subject {Fx('2,4%')}
    it {should_not be_valid}

    specify {
      expect {subject.call(1234)}.to raise_error(ArgumentError)
    }

  end

  describe "#reverse_call" do

    for fx_string, price_with_commission_string in %W[ 1.28% 50 2.83% ].product %W[ 100, 500, 123451.12]

      it "should give correct result for Fx(#{fx_string}) and #{price_with_commission_string}" do
        fx = Fx(fx_string)
        price_with_commission = BigDecimal.new(price_with_commission_string)
        price = price_with_commission - fx.call(price_with_commission)
        fx.reverse_call(price).should == (price_with_commission - price).round(2)
      end

    end

  end

end

# encoding: utf-8
require 'spec_helper'

describe Commission::Formula do

  before do
    Commission::Formula.clear_cache
  end

  include Commission::Fx
  specify { Fx("3").apply.should == 3 }
  specify { Fx("3.5").apply.should == 3.5 }
  specify { Fx("3.5").apply(23).should == 3.5 }
  specify { Fx("3.5%").apply(200).should == 7 }
  pending { Fx("3.5%")[200].should == 7 }
  specify { Fx("2% + 4").to_s.should == "2% + 4" }
  specify { Fx("3.5").should be_valid }
  specify { Fx(" 12.34%").should be_valid }
  specify { Fx("12,34%").should_not be_valid }

  specify { Fx("12.3eur").should be_valid }
  specify { Fx("12.3eur").apply(42, :eur => 43.2).should == 531.36 }

  context "it accepts Numerics" do
    specify { Fx(23.45).should be_valid }
    specify { Fx(23.45).apply.should == 23.45 }
  end

  context "it works with empty values" do
    specify { Fx("").should be_valid }
    specify { Fx("").apply.should == 0 }

    specify { Fx(nil).should be_valid }
    specify { Fx(nil).apply.should == 0 }
  end

  context "works with multiplier" do
    specify { Fx("3.5%").apply(200, :multiplier => 2).should == 7 }
    specify { Fx("3.6").apply(200, :multiplier => 2).should == 7.2 }
    specify { Fx("1.1eur").apply(200, :eur => 24.2, :multiplier => 2).should == 53.24 }
  end

  context "it should round to 2 digits by default" do
    specify { Fx("3.235%").apply(500).should == 16.18 }
  end

  describe "#serialize" do
    specify { Fx('3.34%').inspect.should == '#<Fx 3.34% >' }
  end

  describe "YAML serialization" do
    it "should be serializable by YAML" do
      formula = Fx('3.34%')
      YAML.load(YAML.dump(formula)).should == formula
      # формула не всегда валидна!
      formula.apply(10).should == 0.33
    end

    it "should have exactly that serialization" do
      YAML.dump( Fx('3.34%') ).should == %(--- !fx 3.34%\n...\n)
    end

    it "should have exactly that serialization for empty formula" do
      YAML.dump( Fx(nil) ).should == %(--- !fx \n...\n)
    end

    it "should be backwards compatible with older serialization" do
      serialization = "!ruby/object:Commission::Formula\nformula: 3.34%\n"
      formula = YAML.load(serialization)
      formula.should == Fx('3.34%')
      # формула не всегда валидна!
      formula.apply(10).should == 0.33
    end
  end

  describe "constructor" do
    #explicit
    specify { Fx('rub' => 3).should == Fx('3') }
    specify { Fx('rub' => 3, '%' => 2).should == Fx('3 + 2%') }
    # с нулевыми значениями
    specify { Fx('rub' => 3, '%' => 0).should == Fx('3') }
    specify { Fx('rub' => 0, '%' => 0).should == Fx('0') }
    # FIXME? возможно стоит рейзить в этом случае
    specify { Fx({}).should == Fx('0') }
    specify { Fx('rub' => 3, '%' => -2).should == Fx('3 - 2%') }
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
      subject.apply(100).should == 6.5
    end

    it "should compute with multipliers" do
      subject.apply(100, :multiplier => 4).should == 18.5
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
      expect {subject.apply(1234)}.to raise_error(ArgumentError)
    }

  end

  describe "#reverse_apply" do

    for fx_string, price_with_commission_string in %W[ 1.28% 50 2.83% ].product %W[ 100, 500, 123451.12]

      it "should give correct result for Fx(#{fx_string}) and #{price_with_commission_string}" do
        fx = Fx(fx_string)
        price_with_commission = BigDecimal.new(price_with_commission_string)
        price = price_with_commission - fx.apply(price_with_commission)
        fx.reverse_apply(price).should == (price_with_commission - price).round(2)
      end

    end

  end

  describe "#==" do
    specify { Fx('1').should == Fx('1') }
    specify { Fx('1.0').should == Fx('1') }
    specify { Fx('2% + 1').should == Fx('1 + 2%') }
    specify { Fx('-2.3% + 1').should == Fx('1 - 2.3%') }
    specify { Fx('0').should == Fx('0%') }
    specify { Fx('0usd').should == Fx('0') }
  end

  describe "#+" do
    specify { (Fx('3%') + Fx('4%')).should == Fx('7%') }
    specify { (Fx('3% + 4eur') + Fx('4eur')).should == Fx('3% + 8eur') }
    specify { (Fx('3% + 4') + Fx('5')).should == Fx('3% + 9') }
    specify { (Fx('3% + 4') + Fx('5 + 2%')).should == Fx('5% + 9') }
    specify { (Fx('3% + 4rub') + Fx('5 + 2%')).should == Fx('5% + 9') }
    specify { (Fx('3.0% + 4rub') + Fx('5.0 + 2.1%')).should == Fx('5.1% + 9') }
    specify { (Fx('2%') + Fx('0')).should == Fx('2%') }
  end

  describe "#-" do
    specify { (Fx('3%') - Fx('4%')).should == Fx('-1%') }
    specify { (Fx('3% + 4eur') - Fx('4eur')).should == Fx('3%') }
    specify { (Fx('3% + 4') - Fx('5')).should == Fx('3% - 1') }
    specify { (Fx('3% + 4') - Fx('5 + 2%')).should == Fx('1% - 1') }
    specify { (Fx('3% + 4rub') - Fx('5 + 2%')).should == Fx('1% - 1') }
    specify { (Fx('3.0% + 4rub') - Fx('5.0 + 2.0%')).should == Fx('1% - 1') }
    specify { (Fx('2%') - Fx('0')).should == Fx('2%') }
    specify { (Fx('5') - Fx('1%')).should == Fx('-1% + 5') }
  end

  describe "#parts" do
    specify { Fx('3').parts.should == {'rub' => 3} }
    specify { Fx('3rub').parts.should == {'rub' => 3} }
    specify { Fx('3 + 4%').parts.should == {'rub' => 3, '%' => 4} }
    specify { Fx('2usd + 4%').parts.should == {'usd' => 2, '%' => 4} }
    specify { Fx('2usd - 4%').parts.should == {'usd' => 2, '%' => -4} }
    specify { Fx('0usd').parts.should == {} }
  end

  describe "#<=>" do
    # простые
    specify { Fx('3.34%').should == Fx('3.34%') }
    specify { Fx('3').should > Fx('2') }
    specify { Fx('3').should >= Fx('3') }
    specify { Fx('3').should < Fx('4') }
    specify { Fx('3').should <= Fx('3') }

    # с приоритетом
    specify { Fx('3%').should > Fx('3') }
    specify { Fx('3%').should > Fx('3eur') }
    specify { Fx('3%').should > Fx('3usd') }
    specify { Fx('3%').should > Fx('3rub') }

    # композитные
    specify { Fx('3% + 10.5usd').should > Fx('11usd') }
    specify { Fx('3% + 10.5usd').should > Fx('2% + 10.5usd') }
    specify { Fx('3% + 10.5usd').should < Fx('3.01% + 10.5usd') }
    specify { Fx('3% + 10.5usd').should < Fx('10.5eur + 3%') }
    specify { Fx('3.5% + 5.4').should == Fx('5.4rub + 3.5%') }
  end

  describe "#extract" do
    specify { Fx("5.5% + 1eur").extract("%").should == Fx("5.5%") }
    specify { Fx("1eur").extract("%").should == Fx(0) }
  end

  describe "#round" do
    specify { Fx("5.245% - 1.351eur").round(2).should == Fx("5.25% - 1.35eur") }
  end

  describe "freezed formula arithmetic" do
    it "should compute even in frozen state" do
      first_formula = Fx('3% + 5rub')
      second_formula = Fx('5% + 3rub')
      first_formula.freeze
      second_formula.freeze
      expect {first_formula + second_formula}.to_not raise_error
    end
  end

end


# encoding: utf-8

require 'spec_helper'

describe CommissionRules do

  include Commission::Fx

  context "just one commission" do
    let :commission_class do
      Class.new do
        include CommissionRules

        carrier 'FV'
        commission '2%/3'
      end
    end

    it "should have one commission" do
      commission_class.commissions.size.should == 1
    end

    it "should find a commission for correct recommendation" do
      recommendation = Recommendation.example('SVOCDG', :carrier => 'FV')
      commission_class.find_for(recommendation).should be_a(commission_class)
    end
  end

  context "two carriers, three simple commissions" do
    let :commission_class do
      Class.new do
        include CommissionRules

        carrier 'FV'
        commission '2%/3'
        commission '1%/0'

        carrier 'AB'
        commission '0/0'
      end
    end

    it "should have two airlines" do
      # FIXME вынести подсчет количества комиссий в хелпер
      commission_class.commissions.should have(2).keys
    end

    it "should have registered three commissions" do
      # FIXME вынести подсчет количества комиссий в хелпер
      commission_class.all.should have(3).items
    end

    describe "#exists_for?" do
      specify do
        commission_class.exists_for?(Recommendation.new(:validating_carrier_iata => 'AB')).should be_true
      end

      specify do
        commission_class.exists_for?(Recommendation.new(:validating_carrier_iata => 'S7')).should be_false
      end
    end
  end

  context "all the rules" do
    let :commission_class do
      Class.new do
        include CommissionRules

        carrier 'FV'
        consolidator '1%'
        blanks 50
        discount '2%'
        commission '2%/3'
      end
    end

    let :commission do
      commission_class.all.first
    end

    subject {commission}

    its(:agent) {should == Fx('2%')}
    its(:subagent) {should == Fx(3)}
    its(:consolidator) {should == Fx('1%')}
    its(:blanks) {should == Fx('50')}
  end

  context "setting defaults" do

    let :commission_class do
      Class.new do
        include CommissionRules
        defaults :system => :amadeus,
          :ticketing => :aviacenter,
          :consolidator => '2%',
          :blanks => 23,
          :discount => '5%'

        carrier 'FV'
        commission '2%/3'

        carrier 'AB'
        carrier_defaults :system => :sirena,
          :ticketing => :ours,
          :consolidator => '1%',
          :blanks => 0,
          :discount => '1%'
        commission '1%/1%'
        commission '2%/2%'
      end
    end

    describe ".defaults" do
      context "called correctly" do
        subject { commission_class.for_carrier('FV').first }

        its(:system) { should eq(:amadeus) }
        its(:ticketing) { should eq(:aviacenter) }
        its(:consolidator) { should eq(Fx('2%')) }
        its(:blanks) { should eq(Fx(23)) }
        its(:discount) { should eq(Fx('5%')) }
      end

      context "called with wrong key" do
        it "should raise error" do
          expect {
            Class.new do
              include CommissionRules
              defaults :wrongkey => :wrongvalue
            end
          }.to raise_error(ArgumentError)
        end
      end
    end

    describe ".carrier_defaults" do
      context "called correctly" do
        subject { commission_class.for_carrier('AB').last }

        its(:system) { should eq(:sirena) }
        its(:ticketing) { should eq(:ours) }
        its(:consolidator) { should eq(Fx('1%')) }
        its(:blanks) { should eq(Fx(0)) }
        its(:discount) { should eq(Fx('1%')) }
      end

      context "called with wrong key" do
        it "should raise error" do
          expect {
            Class.new do
              include CommissionRules
              carrier 'FV'
              carrier_defaults :wrongkey => :wrongvalue
            end
          }.to raise_error(ArgumentError)
        end
      end
    end

    describe ".for_carrier" do
      subject { commission_class.for_carrier('AB') }
      it {should be_an(Array)}
      its(:size) { should == 2 }
      its(:first) { should be_an(commission_class) }
    end

    describe ".all" do
      subject { commission_class.all }
      it {should be_an(Array)}
      its(:size) { should == 3 }
      its(:first) { should be_an(commission_class) }
    end
  end
end

# encoding: utf-8

require 'spec_helper'

describe Commission::Reader do

  include Commission::Fx

  context "just one commission" do
    let :commission_class do
      Class.new do
        include Commission::DefaultBook

        carrier 'FV'
        commission '2%/3'
      end
    end

    it "should have one commission" do
      commission_class.commissions.size.should == 1
    end

    it "should find a commission for correct recommendation" do
      recommendation = Recommendation.example('SVOCDG', :carrier => 'FV')
      commission_class.find_for(recommendation).should be_a(Commission::Rule)
    end
  end

  context "two carriers, three simple commissions" do
    let :commission_class do
      Class.new do
        include Commission::DefaultBook

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
        include Commission::DefaultBook

        carrier 'FV'
        consolidator '1%'
        blanks 50
        discount '2%'
        our_markup '1%'
        disabled "because of Caturday, that's why"
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
    its(:our_markup) {should == Fx('1%')}
    its(:discount) {should == Fx('2%')}
    its(:disabled) {should == "because of Caturday, that's why"}
    its(:disabled?) {should be_true}
  end

  context "setting defaults" do

    let :commission_class do
      Class.new do
        include Commission::DefaultBook
        defaults :system => :amadeus,
          :ticketing_method => :aviacenter,
          :consolidator => '2%',
          :blanks => 23,
          :discount => '5%',
          :our_markup => 0

        carrier 'FV'
        commission '2%/3'

        carrier 'AB'
        carrier_defaults :system => :sirena,
          :ticketing_method => :direct,
          :consolidator => '1%',
          :blanks => 0,
          :discount => '1%',
          :our_markup => '1%'
        commission '1%/1%'
        commission '2%/2%'
      end
    end

    describe ".defaults" do
      context "called correctly" do
        subject { commission_class.for_carrier('FV').first }

        its(:system) { should eq(:amadeus) }
        its(:ticketing_method) { should eq(:aviacenter) }
        its(:consolidator) { should eq(Fx('2%')) }
        its(:blanks) { should eq(Fx(23)) }
        its(:discount) { should eq(Fx('5%')) }
        its(:our_markup) { should eq(Fx('0')) }
      end

      context "called with wrong key" do
        it "should raise error" do
          expect {
            Class.new do
              include Commission::DefaultBook
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
        its(:ticketing_method) { should eq(:direct) }
        its(:consolidator) { should eq(Fx('1%')) }
        its(:blanks) { should eq(Fx(0)) }
        its(:discount) { should eq(Fx('1%')) }
        its(:our_markup) { should eq(Fx('1%')) }
      end

      context "called with wrong key" do
        it "should raise error" do
          expect {
            Class.new do
              include Commission::DefaultBook
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
      its(:first) { should be_a(Commission::Rule) }
    end

    describe ".all" do
      subject { commission_class.all }
      it {should be_an(Array)}
      its(:size) { should == 3 }
      its(:first) { should be_a(Commission::Rule) }
    end
  end

  context "several commissions for a company" do

    let :commission_class do
      Class.new do
        include Commission::DefaultBook

        carrier 'FV'
        commission '2%/3'

        carrier 'AB'

        agent "first"
        interline :first
        commission '1%/1%'

        agent "second"
        interline :yes
        commission '2%/2%'

        agent "third"
        interline :no
        important!
        commission '3%/3%'

        agent "fourth"
        interline :possible
        disabled "just because"
        commission "4%/4%"
      end
    end

    let :recommendation do
      Recommendation.example('SVOCDG/SU CDGSVO', :carrier => 'AB')
    end

    specify {
      commission_class.exists_for?(recommendation).should be_true
    }

    specify {
      commission_class.find_for(recommendation).should be_a(Commission::Rule)
    }

    specify {
      commission_class.all_for(recommendation).should have(4).items
    }

    describe ".all_with_reasons_for" do
      subject { commission_class.all_with_reasons_for(recommendation) }

      it {should have(4).items}

      it "should display all commissions in order of importance" do
        subject.map {|row| row[0].agent_comments.strip}.should == %W[third first second fourth]
      end

      it "should have correct statuses" do
        subject.map {|row| row[1]}.should == [:fail, :fail, :success, :skipped]
      end

      it "should have no reason for success" do
        subject[2][2].should be_nil
      end

      it "should display as successful really applied commission" do
        subject.find {|row| row[1] == :success}[0].should == commission_class.find_for(recommendation)
      end
    end

    describe "#number" do
      it "should auto number commissions for every carrier according to source position from 1" do
        commission_class.all.every.number.should == [1, 1, 2, 3, 4]
      end

      it "should apply commissions according to importance" do
        commission_class.all_with_reasons_for(recommendation).every.first.every.number.should == [3, 1, 2, 4]
      end

    end

  end

  context "no_commission commissions for a company" do

    let :commission_class do
      Class.new do
        include Commission::DefaultBook

        carrier 'AB'

        agent "first"
        classes :economy
        commission '1%/1%'

        agent "second"
        classes :business
        no_commission '2%/2% forbidden to sale'

        agent "third"
        classes :business
        commission '3%/3%'
      end
    end

    let :recommendation do
      Recommendation.example('SVOCDG/BUSINESS', :carrier => 'AB')
    end

    specify {
      commission_class.exists_for?(recommendation).should be_true
    }

    it "should not find no_commission commission" do
      commission_class.find_for(recommendation).should be_nil
    end

    specify {
      commission_class.all_for(recommendation).should have(3).items
    }

    describe ".all_with_reasons_for" do
      subject { commission_class.all_with_reasons_for(recommendation) }

      it {should have(3).items}

      it "should have correct statuses" do
        subject.map {|row| row[1]}.should == [:fail, :success, :skipped]
      end

      it "should have no reason for success" do
        subject[1][2].should be_nil
      end

      it "should display as successful really applied commission" do
        subject.find {|row| row[1] == :success}[0].agent_comments.strip.should == "second"
      end
    end

  end

  describe "commission definitions" do
    context "unknown agent commission" do
      let :commission_class do
        Class.new do
          include Commission::DefaultBook

          carrier 'FV'
          commission '/2%'
        end
      end

      subject { commission_class.all.first }

      its(:agent) { should be_blank }
      its(:subagent) { should == Fx('2%') }
    end

    context "unknown subagent commission" do
      let :commission_class do
        Class.new do
          include Commission::DefaultBook

          carrier 'FV'
          commission '2%/'
        end
      end

      subject { commission_class.all.first }

      its(:agent) { should == Fx('2%') }
      its(:subagent) { should be_blank }
    end
  end

  describe "interline rules" do

    RSpec::Matchers.define(:match_recommendation) do |recommendation|
      match do |subject_commission|
        begin
          # FIXME сделать другой выключатель проверки интерлайнов
          old, Commission::Rule.skip_interline_validity_check = Commission::Rule.skip_interline_validity_check, false
          @reason = subject_commission.turndown_reason(recommendation)
        ensure
          Commission::Rule.skip_interline_validity_check = old
        end
        ! @reason
      end

      failure_message_for_should do |subject_commission|
        "expected that '#{recommendation.short}' would match commission, but failed with reason #{@reason.inspect}."
      end

      failure_message_for_should_not do |subject_commission|
        "expected that '#{recommendation.short}' would not match commission."
      end

      description do
        "'#{recommendation.short}' matches commission."
      end
    end

    # определяет класс комиссий с единственным правилом и возвращает это правило
    def commission(&block)

      Class.new do
        include Commission::DefaultBook
        # FIXME дефолт для Recommendation.example
        carrier 'SU'
        # здесь как бы выполняется блок определения комиссии
        instance_eval &block
        # неопределенная агентская/субагентская комиссия
        commission '/'
      end.all.first

    end

    let(:no_interline)             { Recommendation.example('SVOCDG CDGSVO') }
    let(:interline)                { Recommendation.example('SVOCDG/AB CDGSVO') }
    let(:interline_first)          { Recommendation.example('SVOCDG/AB CDGSVO') }
    let(:interline_but_first)      { Recommendation.example('SVOCDG CDGSVO/AB') }
    let(:interline_absent)         { Recommendation.example('SVOCDG/AB CDGSVO/AB') }
    let(:interline_half)           { Recommendation.example('SVOCDG/AB CDGSVO') }
    let(:interline_less_than_half) { Recommendation.example('SVOCDG/AB CDGNCE NCESVO/AB') }

    describe "no interline rules specified (defaults to no interline allowed)" do
      subject do
        commission do
          # nothing here
        end
      end
      it {should match_recommendation( no_interline ) }
      it {should_not match_recommendation( interline ) }
      it {should_not match_recommendation( interline_but_first ) }
      it {should_not match_recommendation( interline_half ) }
      it {should_not match_recommendation( interline_absent ) }
    end

    describe "interline :no" do
      subject do
        commission do
          interline :no
        end
      end
      it {should match_recommendation( no_interline ) }
      it {should_not match_recommendation( interline ) }
      it {should_not match_recommendation( interline_but_first ) }
      it {should_not match_recommendation( interline_half ) }
      it {should_not match_recommendation( interline_absent ) }
    end

    describe "interline :yes" do
      subject do
        commission do
          interline :yes
        end
      end
      it {should_not match_recommendation( no_interline ) }
      it {should match_recommendation( interline ) }
      it {should match_recommendation( interline_but_first ) }
      it {should match_recommendation( interline_half ) }
      it {should_not match_recommendation( interline_absent ) }
    end

    describe "interline :first" do
      subject do
        commission do
          interline :first
        end
      end
      it {should_not match_recommendation( no_interline ) }
      it {should match_recommendation( interline_but_first ) }
      it {should_not match_recommendation( interline_first ) }
      it {should_not match_recommendation( interline_absent ) }
    end

    describe "interline :half" do
      subject do
        commission do
          interline :half
        end
      end
      it {should_not match_recommendation( no_interline ) }
      it {should match_recommendation( interline_half ) }
      it {should_not match_recommendation( interline_less_than_half ) }
      it {should_not match_recommendation( interline_absent ) }
    end

    describe "interline :absent" do
      subject do
        commission do
          interline :absent
        end
      end
      it {should_not match_recommendation( no_interline ) }
      it {should_not match_recommendation( interline ) }
      it {should match_recommendation( interline_absent ) }
    end

    describe "interline :unconfirmed" do
      # на текущий момент, считаем что неподтвержденный интерлайн - работает только при половине собственных рейсов
      subject do
        commission do
          interline :unconfirmed
        end
      end
      it {should_not match_recommendation( no_interline ) }
      it {should match_recommendation( interline_half ) }
      it {should match_recommendation( interline_less_than_half ) }
      it {should_not match_recommendation( interline_absent ) }
    end


    context "combinations of" do
      describe "interline :no, :yes" do
        subject do
          commission do
            interline :no, :yes
          end
        end
        it {should match_recommendation( no_interline ) }
        it {should match_recommendation( interline ) }
        it {should_not match_recommendation( interline_absent ) }
      end

      describe "interline :no, :first" do
        subject do
          commission do
            interline :no, :first
          end
        end
        it {should match_recommendation( no_interline ) }
        it {should match_recommendation( interline_but_first ) }
        it {should_not match_recommendation( interline_first ) }
        it {should_not match_recommendation( interline_absent ) }
      end

      describe "interline :yes, :absent" do
        subject do
          commission do
            interline :yes, :absent
          end
        end
        it {should_not match_recommendation( no_interline ) }
        it {should match_recommendation( interline ) }
        it {should match_recommendation( interline_absent ) }
      end

      describe "interline :no, :unconfirmed" do
        subject do
          commission do
            interline :no, :unconfirmed
          end
        end
        it {should match_recommendation( no_interline ) }
        it {should match_recommendation( interline_half ) }
        it {should match_recommendation( interline_less_than_half ) }
        it {should_not match_recommendation( interline_absent ) }
      end
    end
  end
end

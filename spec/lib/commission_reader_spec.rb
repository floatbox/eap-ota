# encoding: utf-8

require 'spec_helper'

describe Commission::Reader do

  include Commission::Fx

  context "just one commission" do
    subject :book do
      Commission::Reader.new.define do
        carrier 'FV'
        commission '2%/3'
      end
    end

    it "should have one commission" do
      book.all.should have(1).item
    end

    it "should find a commission for correct recommendation" do
      recommendation = Recommendation.example('SVOCDG', :carrier => 'FV')
      book.find_for(recommendation).should be_a(Commission::Rule)
    end
  end

  context "two carriers, three simple commissions" do
    subject :book do
      Commission::Reader.new.define do
        carrier 'FV'
        commission '2%/3'
        commission '1%/0'

        carrier 'AB'
        commission '0/0'
      end
    end

    it "should have two airlines" do
      book.carriers.should == ['FV', 'AB']
    end

    it "should have registered three commissions" do
      book.all.should have(3).items
    end

    describe "#exists_for?" do
      specify do
        book.exists_for?(Recommendation.new(:validating_carrier_iata => 'AB')).should be_true
      end

      specify do
        book.exists_for?(Recommendation.new(:validating_carrier_iata => 'S7')).should be_false
      end
    end
  end

  context "two carriers, four pages" do
    let :book do
      Commission::Reader.new.define do
        carrier 'FV', expr_date: '2013-04-30'
        commission '2%/3'
        commission '1%/0'

        carrier 'FV', strt_date: '2013-05-01', expr_date: '2013-07-31'
        commission '4%/3'

        carrier 'FV', strt_date: '2013-08-01'

        carrier 'AB'
        commission '0/0'
      end
    end

    it "should have two airlines" do
      book.carriers.should == ['FV', 'AB']
    end

    it "should have registered four commissions" do
      book.all.should have(4).items
    end

    it "should define four pages" do
      book.should have(4).pages
    end

    describe "active_pages" do
      pending
    end

    describe "#exists_for?" do
      specify do
        book.exists_for?(Recommendation.new(:validating_carrier_iata => 'FV')).should be_true
      end

      specify do
        book.exists_for?(Recommendation.new(:validating_carrier_iata => 'S7')).should be_false
      end
    end
  end

  context "all the rules" do
    let :book do
      Commission::Reader.new.define do
        carrier 'FV'
        consolidator '1%'
        blanks 50
        discount '2%'
        our_markup '1%'
        disabled "because of Caturday, that's why"
        check { true }
        tour_code "FOOBAR"
        designator "PP10"
        commission '2%/3'
      end
    end

    subject :commission do
      book.all.first
    end

    its(:agent) {should == Fx('2%')}
    its(:subagent) {should == Fx(3)}
    its(:consolidator) {should == Fx('1%')}
    its(:blanks) {should == Fx('50')}
    its(:our_markup) {should == Fx('1%')}
    its(:discount) {should == Fx('2%')}
    its(:disabled) {should == "because of Caturday, that's why"}
    its(:disabled?) {should be_true}
    its(:tour_code) {should == "FOOBAR"}
    its(:designator) {should == "PP10"}
    its(:check_proc) {should be_an_instance_of(Proc)}
  end

  describe "#check" do
    describe "given as code (DEPRECATED)" do
      let :book do
        Commission::Reader.new.define do
          carrier 'SU'
          check {true}
          commission '0/0'
        end
      end

      subject :commission do
        book.all.first
      end

      its(:check) {should eq("# COMPILED")}
      its(:check_proc) {should be_an_instance_of(Proc)}
    end

    describe "given as text" do
      let :book do
        Commission::Reader.new.define do
          carrier 'SU'
          check "true"
          commission '0/0'
        end
      end

      subject :commission do
        book.all.first
      end

      its(:check) {should eq("true")}
      its(:check_proc) {should be_an_instance_of(Proc)}

      it "should return currect value on custom_check" do
        commission.applicable_custom_check?(stub(:recommendation)).should == true
      end
    end

    describe "given syntax error" do

      let(:expected_error_source) { "#{__FILE__}:#{__LINE__ + 7}" }

      subject :book do
        Commission::Reader.new.define do
          carrier 'SU'
          check %[
            false
            1here_should_be_error
            true
          ]
          commission '0/0'
        end
      end

      it "should raise it while reading" do
        expect {book}.to raise_error(SyntaxError)
      end

      it "should raise error with correct_file and line" do
        pending "some problem with Commission::Reader.new.define?"
        message = 'nothing raised?'
        begin
          book
        rescue SyntaxError => e
          message = e.message
        end
        message.should include(expected_error_source)
      end
    end

  end

  context "reader defaults" do

    let :book do
      Commission::Reader.new.define do
        carrier 'FV'
        commission '2%/3'

        carrier 'UN', "Transaero", expr_date: "31.1.2013"
        commission '2%/2%'

        carrier 'UN', strt_date: "1.2.2013"
        commission '1%/1%'
      end
    end

    subject { book.pages_for(carrier: 'FV').first.all.first }

    its(:system) { should eq(:amadeus) }
    its(:consolidator) { should eq(Fx(0)) }
    its(:blanks) { should eq(Fx(0)) }
    its(:discount) { should eq(Fx(0)) }
    its(:our_markup) { should eq(Fx('0')) }
    its(:interline) { should eq([:no]) }


    describe "carrier defaults on repetitive blocks" do
      context "should set defaults correctly" do
        subject :commission do
          book.pages_for(carrier: 'UN').first.all.first
        end

        its(:expr_date) { should eq(Date.new(2013,1,31))}
        its(:strt_date) { should be_nil}
      end

      context "should set defaults for second occurence" do
        subject :commission do
          book.pages_for(carrier: 'UN').last.all.first
        end

        its(:strt_date) { should eq(Date.new(2013,2,1))}
        its(:expr_date) { should be_nil}
        it "should have per page numeration" do
          commission.number.should eq(1)
        end
      end
    end

    describe ".all" do
      subject { book.all }
      it {should be_an(Array)}
      its(:size) { should == 3 }
      its(:first) { should be_a(Commission::Rule) }
    end
  end

  context "several commissions for a company" do

    let :book do
      Commission::Reader.new.define do
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
      book.exists_for?(recommendation).should be_true
    }

    specify {
      book.find_for(recommendation).should be_a(Commission::Rule)
    }

    specify {
      book.pages_for(carrier: 'AB').first.should have(4).commissions
    }

    describe ".all_with_reasons_for" do
      subject { book.all_with_reasons_for(recommendation) }

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
        subject.find {|row| row[1] == :success}[0].should == book.find_for(recommendation)
      end
    end

    describe "#number" do
      it "should auto number commissions for every carrier according to source position from 1" do
        book.all.every.number.should == [1, 1, 2, 3, 4]
      end

      it "should apply commissions according to importance" do
        book.all_with_reasons_for(recommendation).every.first.every.number.should == [3, 1, 2, 4]
      end

    end

  end

  context "no_commission commissions for a company" do

    let :book do
      Commission::Reader.new.define do
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
      book.exists_for?(recommendation).should be_true
    }

    it "should not find no_commission commission" do
      book.find_for(recommendation).should be_nil
    end

    specify {
      book.pages_for(carrier: 'AB').first.should have(3).commissions
    }

    describe ".all_with_reasons_for" do
      subject { book.all_with_reasons_for(recommendation) }

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
      let :book do
        Commission::Reader.new.define do
          carrier 'FV'
          commission '/2%'
        end
      end

      subject { book.all.first }

      its(:agent) { should be_blank }
      its(:subagent) { should == Fx('2%') }
    end

    context "unknown subagent commission" do
      let :book do
        Commission::Reader.new.define do
          carrier 'FV'
          commission '2%/'
        end
      end

      subject { book.all.first }

      its(:agent) { should == Fx('2%') }
      its(:subagent) { should be_blank }
    end
  end
end

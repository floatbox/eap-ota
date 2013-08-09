# encoding: utf-8

require 'spec_helper'

describe Commission::Reader do

  include Commission::Fx

  context "just one commission" do
    subject :book do
      Commission::Reader.new.define do
        carrier 'FV'
        rule 1 do
          agent "2%"
        end
      end
    end

    it "should have one commission" do
      book.rules.should have(1).item
    end

    it "should find a commission for correct recommendation" do
      recommendation = Recommendation.example('SVOCDG', :carrier => 'FV')
      book.find_rule_for_rec(recommendation).should be_a(Commission::Rule)
    end
  end

  context "two carriers, three simple rules" do
    subject :book do
      Commission::Reader.new.define do
        carrier 'FV'

        rule 1 do
        agent "2%"
        end

        rule 2 do
        agent "1%"
        end

        carrier 'AB'

        rule 1 do
        agent "0"
        end
      end
    end

    it "should have two airlines" do
      book.carriers.should == ['FV', 'AB']
    end

    it "should have registered three rules" do
      book.should have(3).rules
    end
  end

  context "two carriers, four pages" do
    let :book do
      Commission::Reader.new.define do
        carrier 'FV'
        rule 1 do
          agent "2%"
        end
        rule 2 do
          agent "1%"
        end

        carrier 'FV', start_date: '2013-05-01'
        rule 1 do
          agent "4%"
        end

        carrier 'FV', start_date: '2013-08-01'

        carrier 'AB'
        rule 1 do
          agent "0"
        end
      end
    end

    it "should have two airlines" do
      book.carriers.should == ['FV', 'AB']
    end

    it "should have registered four rules" do
      book.should have(4).rules
    end

    it "should define four pages" do
      book.should have(4).pages
    end

    describe "active_pages" do
      pending
    end

  end

  context "all the rules" do
    let :book do
      Commission::Reader.new.define do
        carrier 'FV'
        rule 1 do
        consolidator '1%'
        blanks 50
        discount '2%'
        our_markup '1%'
        disabled "because of Caturday, that's why"
        check %{ true }
        tour_code "FOOBAR"
        designator "PP10"
        agent "2%"
        subagent "3"
        end
      end
    end

    subject :rule do
      book.rules.first
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

    describe "given as text" do
      let :book do
        Commission::Reader.new.define do
          carrier 'SU'
          rule 1 do
          check "true"
          agent "0"
          end
        end
      end

      subject :rule do
        book.rules.first
      end

      its(:check) {should eq("true")}
      its(:check_proc) {should be_an_instance_of(Proc)}

      it "should return currect value on custom_check" do
        rule.applicable_custom_check?(stub(:recommendation)).should == true
      end
    end

    describe "given syntax error" do

      let(:expected_error_source) { "#{__FILE__}:#{__LINE__ + 7}" }

      subject :book do
        Commission::Reader.new.define do
          carrier 'SU'
          rule 1 do
          check %[
            false
            1here_should_be_error
            true
          ]
          agent "0"
          end
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
        rule 1 do
        agent "2%"
        subagent "3"
        end

        carrier 'UN', start_date: "1.2.2013"
        rule 1 do
        agent "1%"
        subagent "1%"
        end

        carrier 'UN'
        rule 1 do
        agent "2%"
        subagent "2%"
        end
      end
    end

    subject { book.pages_for(carrier: 'FV').first.rules.first }

    its(:system) { should eq(:amadeus) }
    its(:consolidator) { should eq(Fx(0)) }
    its(:blanks) { should eq(Fx(0)) }
    its(:discount) { should eq(Fx(0)) }
    its(:our_markup) { should eq(Fx('0')) }
    its(:interline) { should eq([:no]) }


    describe "carrier defaults on repetitive blocks" do
      context "should set defaults correctly" do
        subject :page do
          book.pages_for(carrier: 'UN').last
        end

        its(:start_date) { should be_nil }
      end

      context "should set defaults for second occurence" do
        subject :page do
          book.pages_for(carrier: 'UN').first
        end

        its(:start_date) { should eq(Date.new(2013,2,1))}
        it "should have per page numeration" do
          page.rules.first.number.should eq(1)
        end
      end
    end

    describe ".rules" do
      subject { book.rules }
      it {should be_an(Array)}
      its(:size) { should == 3 }
      its(:first) { should be_a(Commission::Rule) }
    end
  end

  context "several rules for a company" do

    let :book do
      Commission::Reader.new.define do
        carrier 'FV'

        rule 1 do
        agent "2%"
        subagent "3"
        end

        carrier 'AB'

        rule 1 do
        agent_comment "first"
        interline :first
        agent "1%"
        subagent "1%"
        end

        rule 2 do
        agent_comment "second"
        interline :yes
        agent "2%"
        subagent "2%"
        end

        rule 3 do
        agent_comment "third"
        interline :no
        important!
        agent "3%"
        subagent "3%"
        end

        rule 4 do
        agent_comment "fourth"
        interline :possible
        disabled "just because"
        agent "4%"
        subagent "4%"
        end
      end
    end

    let :recommendation do
      Recommendation.example('SVOCDG/SU CDGSVO', :carrier => 'AB')
    end

    specify {
      book.find_rule_for_rec(recommendation).should be_a(Commission::Rule)
    }

    specify {
      book.pages_for(carrier: 'AB').first.should have(4).rules
    }

    describe ".all_with_reasons_for" do
      subject { book.all_with_reasons_for(recommendation) }

      it {should have(4).items}

      it "should display all rules in order of importance" do
        subject.map {|row| row[0].agent_comments.strip}.should == %W[third first second fourth]
      end

      it "should have correct statuses" do
        subject.map {|row| row[1]}.should == [:fail, :fail, :success, :skipped]
      end

      it "should have no reason for success" do
        subject[2][2].should be_nil
      end

      it "should display as successful really applied rule" do
        subject.find {|row| row[1] == :success}[0].should == book.find_rule_for_rec(recommendation)
      end
    end

    describe "#number" do
      it "should auto number rules for every carrier according to source position from 1" do
        book.rules.every.number.should == [1, 1, 2, 3, 4]
      end

      it "should apply rules according to importance" do
        book.all_with_reasons_for(recommendation).every.first.every.number.should == [3, 1, 2, 4]
      end

    end

  end

  context "no_commission rules for a company" do

    let :book do
      Commission::Reader.new.define do
        carrier 'AB'

        rule 1 do
        agent_comment "first"
        classes :economy
        agent "1%"
        subagent "1%"
        end

        rule 2 do
        agent_comment "second"
        classes :business
        no_commission '2%/2% forbidden to sale'
        end

        rule 3 do
        agent_comment "third"
        classes :business
        agent "3%"
        subagent "3%"
        end
      end
    end

    let :recommendation do
      Recommendation.example('SVOCDG/BUSINESS', :carrier => 'AB')
    end

    it "should find no_commission rule" do
      book.find_rule_for_rec(recommendation).should_not be_sellable
    end

    specify {
      book.pages_for(carrier: 'AB').first.should have(3).rules
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

      it "should display as successful really applied rules" do
        subject.find {|row| row[1] == :success}[0].agent_comments.strip.should == "second"
      end
    end

  end

  describe "commission definitions" do
    context "unknown agent commission" do
      let :book do
        Commission::Reader.new.define do
          carrier 'FV'
          rule 1 do
          subagent '2%'
          end
        end
      end

      subject { book.rules.first }

      its(:agent) { should be_blank }
      its(:subagent) { should == Fx('2%') }
    end

    context "unknown subagent commission" do
      let :book do
        Commission::Reader.new.define do
          carrier 'FV'
          rule 1 do
          agent "2%"
          end
        end
      end

      subject { book.rules.first }

      its(:agent) { should == Fx('2%') }
      its(:subagent) { should be_blank }
    end
  end
end

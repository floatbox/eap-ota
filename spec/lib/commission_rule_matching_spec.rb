# encoding: utf-8

require 'spec_helper'

describe Commission::Rule::Matching do

  describe "interline rules" do

    RSpec::Matchers.define(:match_recommendation) do |recommendation|
      match do |subject_rule|
        begin
          # FIXME сделать другой выключатель проверки интерлайнов
          old, Commission::Rule.skip_interline_validity_check = Commission::Rule.skip_interline_validity_check, false
          @reason = subject_rule.turndown_reason(recommendation)
        ensure
          Commission::Rule.skip_interline_validity_check = old
        end
        ! @reason
      end

      failure_message_for_should do |subject_rule|
        "expected that '#{recommendation.short}' would match rule, but failed with reason #{@reason.inspect}."
      end

      failure_message_for_should_not do |subject_rule|
        "expected that '#{recommendation.short}' would not match rule."
      end

      description do
        "'#{recommendation.short}' matches rule."
      end
    end

    # считывает одно единственное правило
    # FIXME может быть, прокинуть в define перевозчика?
    def rule(&block)
      Commission::Reader::Rule.new.define(&block)
    end

    let(:no_interline)             { Recommendation.example('SVOCDG CDGSVO') }
    let(:codeshare)                { Recommendation.example('SVOCDG CDGSVO/AB:SU') }
    let(:interline)                { Recommendation.example('SVOCDG/AB CDGSVO') }
    let(:interline_first)          { Recommendation.example('SVOCDG/AB CDGSVO') }
    let(:interline_but_first)      { Recommendation.example('SVOCDG CDGSVO/AB') }
    let(:interline_absent)         { Recommendation.example('SVOCDG/AB CDGSVO/AB') }
    let(:interline_half)           { Recommendation.example('SVOCDG/AB CDGSVO') }
    let(:interline_less_than_half) { Recommendation.example('SVOCDG CDGNCE NCESVO/AB') }
    let(:interline_more_than_half) { Recommendation.example('SVOCDG/AB CDGNCE/AB NCESVO') }

    describe "no interline rules specified (defaults to no interline allowed)" do
      subject do
        rule do
          # nothing here
        end
      end
      it {should match_recommendation( codeshare ) }
      it {should match_recommendation( no_interline ) }
      it {should_not match_recommendation( interline ) }
      it {should_not match_recommendation( interline_but_first ) }
      it {should_not match_recommendation( interline_half ) }
      it {should_not match_recommendation( interline_absent ) }
    end

    describe "interline :no" do
      subject do
        rule do
          interline :no
        end
      end
      it {should match_recommendation( codeshare ) }
      it {should match_recommendation( no_interline ) }
      it {should_not match_recommendation( interline ) }
      it {should_not match_recommendation( interline_but_first ) }
      it {should_not match_recommendation( interline_half ) }
      it {should_not match_recommendation( interline_absent ) }
    end

    describe "interline :no_codeshare" do
      subject do
        rule do
          interline :no_codeshare
        end
      end
      it {should_not match_recommendation( codeshare ) }
      it {should match_recommendation( no_interline ) }
      it {should_not match_recommendation( interline ) }
      it {should_not match_recommendation( interline_but_first ) }
      it {should_not match_recommendation( interline_half ) }
      it {should_not match_recommendation( interline_absent ) }
    end

    describe "interline :yes" do
      subject do
        rule do
          interline :yes
        end
      end
      it {should_not match_recommendation( codeshare ) }
      it {should_not match_recommendation( no_interline ) }
      it {should match_recommendation( interline ) }
      it {should match_recommendation( interline_but_first ) }
      it {should match_recommendation( interline_half ) }
      it {should match_recommendation( interline_more_than_half ) }
      it {should_not match_recommendation( interline_absent ) }
    end

    describe "interline :first" do
      subject do
        rule do
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
        rule do
          interline :half
        end
      end
      it {should_not match_recommendation( no_interline ) }
      it {should match_recommendation( interline_half ) }
      it {should match_recommendation( interline_less_than_half ) }
      it {should_not match_recommendation( interline_more_than_half ) }
      it {should_not match_recommendation( interline_absent ) }
    end

    describe "interline :less_than_half" do
      subject do
        rule do
          interline :less_than_half
        end
      end
      it {should_not match_recommendation( no_interline ) }
      it {should_not match_recommendation( interline_half ) }
      it {should match_recommendation( interline_less_than_half ) }
      it {should_not match_recommendation( interline_more_than_half ) }
      it {should_not match_recommendation( interline_absent ) }
    end

    describe "interline :absent" do
      subject do
        rule do
          interline :absent
        end
      end
      it {should_not match_recommendation( codeshare ) }
      it {should_not match_recommendation( no_interline ) }
      it {should_not match_recommendation( interline ) }
      it {should match_recommendation( interline_absent ) }
    end

    describe "interline :unconfirmed" do
      # на текущий момент, считаем что неподтвержденный интерлайн - работает только при половине собственных рейсов
      subject do
        rule do
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
          rule do
            interline :no, :yes
          end
        end
        it {should match_recommendation( no_interline ) }
        it {should match_recommendation( interline ) }
        it {should_not match_recommendation( interline_absent ) }
      end

      describe "interline :no, :first" do
        subject do
          rule do
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
          rule do
            interline :yes, :absent
          end
        end
        it {should_not match_recommendation( no_interline ) }
        it {should match_recommendation( interline ) }
        it {should match_recommendation( interline_absent ) }
      end

      describe "interline :no, :unconfirmed" do
        subject do
          rule do
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

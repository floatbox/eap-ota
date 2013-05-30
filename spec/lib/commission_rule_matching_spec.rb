# encoding: utf-8

require 'spec_helper'

describe Commission::Rule::Matching do

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

      Commission::Reader.new.define do
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
    let(:interline_less_than_half) { Recommendation.example('SVOCDG CDGNCE NCESVO/AB') }
    let(:interline_more_than_half) { Recommendation.example('SVOCDG/AB CDGNCE/AB NCESVO') }

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
      it {should match_recommendation( interline_more_than_half ) }
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
      it {should match_recommendation( interline_less_than_half ) }
      it {should_not match_recommendation( interline_more_than_half ) }
      it {should_not match_recommendation( interline_absent ) }
    end

    describe "interline :less_than_half" do
      subject do
        commission do
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

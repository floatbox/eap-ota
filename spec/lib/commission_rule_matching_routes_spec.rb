# encoding: utf-8

require 'spec_helper'

describe Commission::Rule::Matching do

  describe "routes" do

    RSpec::Matchers.define(:match_route) do |route|
      match_for_should do |routexes|
        @recommendation = mock(Recommendation, route: route)
        @rule = Commission::Rule.new(routes: Array(routexes))
        @rule.applicable_routes?(@recommendation)
      end

      failure_message_for_should do |routex|
        "expected that #{routex.inspect} would match #{route.inspect}, " +
          "compiled_positive_routes: #{@rule.compiled_positive_routes.inspect}, " +
          "compiled_negative_routes: #{@rule.compiled_negative_routes.inspect}"
      end
    end

    describe 'simple routes' do
      subject {'MOW-PAR'}
      it {should match_route('MOW-PAR')}
      it {should_not match_route('MOW-PAR-MOW')}
      it {should_not match_route('PAR-MOW')}
      it {should_not match_route('EKB-MOW-PAR')}
    end

    describe 'simple modificators' do
      describe 'OW' do
        subject {'MOW-PAR/OW'}
        it {should match_route('MOW-PAR')}
        it {should_not match_route('MOW-PAR-MOW')}
        it {should_not match_route('PAR-MOW')}
      end

      describe 'OW,RT' do
        subject {'MOW-PAR/OW,RT'}
        it {should match_route('MOW-PAR')}
        it {should match_route('MOW-PAR-MOW')}
        it {should_not match_route('PAR-MOW')}
      end

      describe 'OW,RT,TR,WO' do
        subject {'MOW-PAR/OW,RT,TR,WO'}
        it {should match_route('MOW-PAR')}
        it {should match_route('MOW-PAR-MOW')}
        it {should match_route('PAR-MOW')}
        it {should match_route('MOW-PAR-MOW')}
        it {should_not match_route('MOW-PAR-LED')}
      end

      describe 'ALL' do
        subject {'MOW-PAR/ALL'}
        it {should match_route('MOW-PAR')}
        it {should match_route('MOW-PAR-MOW')}
        it {should match_route('PAR-MOW')}
        it {should match_route('MOW-PAR-MOW')}
        it {should_not match_route('MOW-PAR-LED')}
      end
    end

    describe "ellipsis (...)" do
      describe 'simple case' do
        subject {'...MOW...'}
        it {should match_route('PAR-MOW-PAR')}
        it {should match_route('MOW-PAR')}
        it {should match_route('MOW-PAR-MOW')}
      end
      describe 'simple case #2' do
        subject {'LED...MOW'}
        it {should match_route('LED-MOW')}
        it {should match_route('LED-EKB-UFA-MOW')}
        it {should_not match_route('LED-MOW-LED')}
      end
      describe 'with modifiers' do
        subject {'LED...MOW/RT'}
        it {should_not match_route('LED-UFA-MOW')}
        it {should match_route('LED-MOW-UFA-LED')}
      end
    end

    describe "comma enumerations" do
      describe 'simple case' do
        subject {'MOW,LED-PAR'}
        it {should match_route('MOW-PAR')}
        it {should match_route('LED-PAR')}
        it {should_not match_route('PAR-MOW')}
        it {should_not match_route('MOW-PAR-MOW')}
        it {should_not match_route('LED-MOW-PAR')}
      end

      describe 'with modifiers' do
        subject {'MOW,LED-PAR/OW,RT'}
        it {should match_route('MOW-PAR')}
        it {should match_route('LED-PAR')}
        it {should_not match_route('PAR-MOW')}
        it {should match_route('MOW-PAR-LED')}
      end
    end

    describe "countries" do
      describe 'simple case' do
        subject {'RU-PAR'}
        it {should match_route('MOW-PAR')}
        it {should_not match_route('PAR-MOW-PAR')}
      end
      describe 'mixed case' do
        subject {'US...RU/OW,RT'}
        it {should match_route('NYC-PAR-MOW-PAR-NYC')}
        it {should_not match_route('MOW-NYC')}
      end
    end

    describe "negative routes" do
      subject {'^RU-PAR'}
      it {should_not match_route('MOW-PAR')}
      it {should match_route('PAR-MOW-PAR')}
    end

    describe "combination of negative and positive" do
      subject { ['^RU...', '^US-RU/ALL', 'PAR-MOW/RT', 'MOW-PAR...']}
      it {should match_route('PAR-MOW-PAR')}
      it {should_not match_route('MOW-PAR-MOW')}
    end

    describe "bad syntax" do
      pending
    end
  end
end

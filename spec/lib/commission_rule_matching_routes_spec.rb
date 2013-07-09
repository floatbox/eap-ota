# encoding: utf-8

require 'spec_helper'

describe Commission::Rule::Matching do

  describe "routes" do

    RSpec::Matchers.define(:match_route) do |route|
      match_for_should do |routex|
        @recommendation = mock(Recommendation, route: route)
        @rule = Commission::Rule.new(routes: [routex])
        @rule.applicable_routes?(@recommendation)
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
      pending
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

    describe "bad syntax" do
      pending
    end
  end
end

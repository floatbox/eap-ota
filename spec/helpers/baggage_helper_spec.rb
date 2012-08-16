# encoding: utf-8
require 'spec_helper'

describe BaggageHelper do

  describe '#baggage_summary' do
    subject do
      baggage_summary(baggage_limitations)
    end

    context 'only hand luggage' do
      let(:baggage_limitations) do
        [BaggageLimit.new(:baggage_quantity => 0, :baggage_type => 'N'),
         BaggageLimit.new(:baggage_quantity => 0, :baggage_type => 'N')]
      end
      it {should == 'только ручная кладь'}
    end

    context 'unknown luggage' do
      let(:baggage_limitations) do
        [BaggageLimit.new(:baggage_quantity => 0, :baggage_type => 'N'),
         BaggageLimit.new()]
      end
      it {should be_nil}
    end

    context 'unknown luggage again' do
      let(:baggage_limitations) do
        []
      end
      it {should be_nil}
    end

    context '2 units' do
      let(:baggage_limitations) do
        [BaggageLimit.new(:baggage_quantity => 2, :baggage_type => 'N')]
      end
      it {should == '2&nbsp;места'.html_safe}
    end

    context '2 units again' do
      let(:baggage_limitations) do
        [BaggageLimit.new(:baggage_quantity => 1, :baggage_type => 'N'),
         BaggageLimit.new(:baggage_quantity => 1, :baggage_type => 'N')]
      end
      it {should == '2 x 1&nbsp;место'.html_safe}
    end

    context '20 kg' do
      let(:baggage_limitations) do
        [BaggageLimit.new(:baggage_weight => 20, :baggage_type => 'W', :measure_unit => 'K')]
      end
      it {should == '20&nbsp;кг'.html_safe}
    end

    context '2 x 20 kg' do
      let(:baggage_limitations) do
        [BaggageLimit.new(:baggage_weight => 20, :baggage_type => 'W', :measure_unit => 'K'),
         BaggageLimit.new(:baggage_weight => 20, :baggage_type => 'W', :measure_unit => 'K')]
      end
      it {should == '2 x 20&nbsp;кг'.html_safe}
    end

    context '2 units + 2 x 20 kg' do
      let(:baggage_limitations) do
        [BaggageLimit.new(:baggage_quantity => 2, :baggage_type => 'N'),
         BaggageLimit.new(:baggage_weight => 20, :baggage_type => 'W', :measure_unit => 'K'),
         BaggageLimit.new(:baggage_weight => 20, :baggage_type => 'W', :measure_unit => 'K')]
      end
      it {should == '2&nbsp;места +<br>2 x 20&nbsp;кг'.html_safe}
    end

    context '10 lb' do
      let(:baggage_limitations) do
        [BaggageLimit.new(:baggage_weight => 10, :baggage_type => 'W', :measure_unit => 'L')]
      end
      it {should == '10&nbsp;lb'.html_safe}
    end
  end

end

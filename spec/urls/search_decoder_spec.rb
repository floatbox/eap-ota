# encoding: utf-8
require 'spec_helper'

describe Urls::Search::Decoder do

  let(:filler) { Urls::Search::FILLER_CHARACTER }

  def parsed?(url)
    Urls::Search::Decoder.new(url).valid?
  end

  context 'valid' do

    context 'one-way ticket search' do

      before(:all) do
        @url = 'Y100MOWPAR08AUG13'
        @decoder = Urls::Search::Decoder.new(@url)
      end

      subject { @decoder }

      its(:valid?) { should be_true }
      its(:adults?) { should be_true }
      its(:children?) { should be_false }
      its(:infants?) { should be_false }

      describe 'decoded' do

        subject { @decoder.decoded }

        it { should_not be_nil }
        its(:adults) { should == 1 }
        its(:children) { should == 0 }
        its(:infants) { should == 0 }
        its(:cabin) { should == 'Y' }

        describe 'segments' do
          subject { @decoder.decoded.segments }
          it { should have(1).items }
          it { should }
        end
      end
    end

    specify 'lowercase' do
      parsed?('b100mowpar08AUG13').should be_true
    end

    specify('with filler character') { parsed?("Y100MOWPA#{filler}08AUG13").should be_true }
    # для случая с включением сирены
    specify('with cyrillic iatas') { parsed?('C100СПБPAR08AUG13').should be_true }
    specify('with cyrillic lowercase iatas') { parsed?('C100спбPAR08AUG13').should be_true }
  end

  context 'invalid url with' do
    specify('completely wrong url') { parsed?('foowalksintothebar').should be_false }
    specify('wrong length') { parsed?('Y100MOWPAR08813').should be_false }
    specify('misplaced filler character') { parsed?("Y009A#{filler}SPAR08AUG13").should be_false }
    specify('wrong adults value') { parsed?('YM00MOWPAR08AUG13').should be_false }
    specify('big adults value') { parsed?('Y900MOWPAR08AUG13').should be_false }
    specify('wrong children value') { parsed?('Y0z0MOWPAR08AUG13').should be_false }
    specify('big children value') { parsed?('Y090MOWPAR08AUG13').should be_false }
    specify('wrong infants value') { parsed?('Y00zMOWPAR08AUG13').should be_false }
    specify('big infants value') { parsed?('Y009MOWPAR08AUG13').should be_false }
    specify('iata with numbers') { parsed?('Y009M9WPAR08AUG13').should be_false }
    specify('iata with wrong filler character') { parsed?('Y009MO*PAR08AUG13').should be_false }
    specify('7 segments') { parsed?('Y009' + 'MOWPAR08AUG13' * 7).should be_false }
  end
end


# encoding: utf-8
require 'spec_helper'

describe Urls::Search::Decoder do
  before do
    Time.stub(:now).and_return(Date.parse('14JUL2013'))
  end

  let(:filler) { Urls::Search::FILLER_CHARACTER }

  def parsed?(url)
    Urls::Search::Decoder.new(url).valid?
  end

  context 'valid' do

    context 'one-way ticket search' do

      before(:all) do
        @url = 'MOW-PAR-Aug8'
        @decoder = Urls::Search::Decoder.new(@url)
      end

      subject { @decoder }

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

    context 'two-way ticket search' do

      before(:all) do
        @url = 'MOW-PAR-Aug8;Aug16'
        @decoder = Urls::Search::Decoder.new(@url)
      end

      subject { @decoder }

      its(:valid?) { should be_true }

      describe 'segments' do

        subject { @decoder.decoded.segments }

        it { should have(2).items }

        describe 'last segment' do

          subject { @decoder.decoded.segments.second }

          its(:from) { should == 'PAR' }
          its(:to) { should == 'MOW' }
          its(:date) { should == '160813' }
        end
      end

    end

    context 'implicit date' do
      it 'should be current year' do
        url = 'MOW-PAR-Sep8'
        decoder = Urls::Search::Decoder.new(url)
        decoder.decoded.segments.last.date.should == '080913'
      end

      it 'should be next year' do
        url = 'MOW-PAR-Feb8'
        decoder = Urls::Search::Decoder.new(url)
        decoder.decoded.segments.last.date.should == '080214'
      end
    end

    context 'complex route(6 segments)' do

      before(:all) do
        @url = 'MOW-PAR-Aug8;PAR-AMS-Aug16;AMS-CHC-Aug18;CHC-AMS-Aug25;AMS-PAR-Sep1;PAR-MOW-Sep5'
        @decoder = Urls::Search::Decoder.new(@url)
      end

      subject { @decoder }

      its(:valid?) { should be_true }

      describe 'segments' do

        subject { @decoder.decoded.segments }

        it { should have(6).items }

        describe 'fifth segment' do

          subject { @decoder.decoded.segments[4] }

          its(:from) { should == 'AMS' }
          its(:to) { should == 'PAR' }
          its(:date) { should == '010913' }
        end
      end

    end

    context 'shortened complex route(6 segments)' do

      before(:all) do
        @url = 'MOW-PAR-Aug8;AMS-Aug16;CHC-Aug18;AMS-Aug25;PAR-Sep1;MOW-Sep5'
        @decoder = Urls::Search::Decoder.new(@url)
      end

      subject { @decoder }

      its(:valid?) { should be_true }

      describe 'segments' do

        subject { @decoder.decoded.segments }

        it { should have(6).items }

        describe 'fifth segment' do

          subject { @decoder.decoded.segments[4] }

          its(:from) { should == 'AMS' }
          its(:to) { should == 'PAR' }
          its(:date) { should == '010913' }
        end
      end

    end

    context 'children and class' do

      before(:all) do
        @url = 'MOW-PAR-Aug8;PAR-AMS-Aug16;2adt;inf;business'
        @decoder = Urls::Search::Decoder.new(@url)
      end

      subject { @decoder }

      its(:valid?) { should be_true }

      describe 'segments' do
        subject { @decoder.decoded.segments }
        it { should have(2).items }
      end

      describe 'passengers' do
        subject { @decoder.decoded }
        its(:adults) { should == 2 }
        its(:children) { should == 0 }
        its(:infants) { should == 1 }
        its(:cabin) { should == 'C' }
      end
    end

    # specify('lowercase') { parsed?('b100mowpar08AUG').should be_true }
    # specify('with filler character') { parsed?("Y100MOWPA#{filler}08AUG").should be_true }
    # для сирены
    # specify('with cyrillic iatas') { parsed?('C100СПБPAR08AUG').should be_true }
    # specify('with cyrillic lowercase iatas') { parsed?('C100спбPAR08AUG').should be_true }
    # specify('with filler character') { parsed?("C100MO#{filler}PAR08AUG").should be_true }
  end


  context 'invalid url with' do

    next "not needed yet"

    specify('completely wrong url') { parsed?('foowalksintothebar').should be_false }
    # specify('wrong length') { parsed?('Y100MOWPAR088').should be_false }
    specify('wrong adults value') { parsed?('YM00MOWPAR08AUG').should be_false }
    specify('wrong children value') { parsed?('Y0z0MOWPAR08AUG').should be_false }
    specify('wrong infants value') { parsed?('Y00zMOWPAR08AUG').should be_false }
    specify('7 segments') { parsed?('Y009' + 'MOWPAR08AUG' * 7).should be_false }
  end
end

